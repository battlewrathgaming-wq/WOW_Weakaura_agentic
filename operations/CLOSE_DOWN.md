# CLOSE DOWN — the project ended 2026-08-29, and this is the state it ended in

> ★★★ **READ THIS BEFORE ANY OTHER FILE IN THE REPO.** Every inbox, acceptance doc and lane file
> below still reads as *live work in progress*, because that is how they were left. **They are not
> waiting on anybody.** Nothing in this repository is pending, blocked, or owed. If a document
> asks a question, no one is going to answer it.

**Why.** Project Ascension announced that all emulated WoW realms shut down **2026-09-05**, by
mutual agreement with Blizzard; WoW content leaves their site, socials and launcher after that date
(`ARCHITECT_LOG.md` AL-79). Battlewrath's call, the day after: *"We'll be shutting down all works.
Without the live env, our bench has nothing to work against or product to offer."*

⚠ **That is a product judgement, not a technical one, and it is the correct one.** The offline
bench still runs — the Lua emulator, the frame model, the checkers and the renderer path all read
local files and never touched a realm. What ended is the *audience*: a dungeon-route authoring tool
with no server to drive on has no user, and no amount of working machinery changes that.

**Written by** the Addon creator at Battlewrath's ask — *"You can bundle a close down package for
warm start. From all seats, rather than ritual."* ⟶ Not a ceremony per seat: one package, measured
this turn rather than recalled, covering what every seat actually left behind.

---

## 1 · THE ONE-SCREEN ANSWER

    what it was      a multi-agent bench building WoW addons, class theorycraft and WeakAuras for
                     Project Ascension's "Conquest of Azeroth" — Battlewrath owning vision, taste
                     and class knowledge; agent seats owning implementation and record-keeping
    the flagship     `COA_DungeonRun` — author a dungeon route as beacons and children, then
                     drive it: a sensor watching distance, a manager advancing stage/step, action
                     tabs gating completion
    how far it got   the AUTHORING surface is complete and the RUNTIME loop closes. It was never
                     driven end to end by a player on a live realm.
    the ledger       1663 commits, the last being §760
    preservation     `F:/Projects_games/COA_preservation_2026-09/` — five verified archives plus
                     `MANIFEST.md`, written for a reader arriving cold in five years

---

## 2 · WHAT IS FINISHED, AND WOULD WORK

Eight addons under `addons/`: `COA_DungeonRun` · `COA_Landmarks` · `COA_DevDump` · `COA_PetGrid` ·
`COA_GuardianPlates` · `COA_StatePlates_Aggro` / `_Enemy` / `_Friendly`.

**`COA_DungeonRun` is the one with depth.** Its node lane authors ten controls
(`stage · ordinal · note · next · nextArg · trigger · reach · band · tabs · ledTo`), and the run
closes: the sensor computes transitions, the manager consumes them on two rails (instant up,
hysteresis down), the doors observe over CallbackHandler with one writer per field.

⚠ **It ships as the TEST DRIVE only, and that is the architecture, not a gap.** Battlewrath's
ruling: *"Dungeon Routes ships the real actor; Dungeon Run ships the test-drive twin"* — the
rehearsal flag is which actor is loaded, not a switch inside one. A walk that reports the manager
as *"reachable only from `drive.lua`"* has found the correct end state (`Addons_load.md` §748
records this correction to itself).

**The bench apparatus is the other finished thing, and it is the more transferable one.** 72 Python
tools, of which **16 are checkers, all 16 proven able to go red** by their own mutation suite; 31
Lua smokes running against an offline FrameXML/Ace emulator; **422 mutation rows for
`COA_DungeonRun`, 415 biting on their own message.** None of that needed a realm and none of it is
Ascension-specific in principle.

---

## 3 · WHAT EACH SEAT LEFT — measured this turn

### Addon creator (implementation, git, records)

Trunk pushed through §759; §760 is the push receipt behind it. Last builds: the node-wide `sense`
control struck (§754), `nextArg` hidden off `set` (§754), the doc-freshness tier rule built (§757).

    ☐ abandoned   RI-81's three one-liners (filed TO this bench, never built) · RI-54's directed
                  work list · RI-43's three code items
    ☐ A6.1/A6.2   the two acceptance criteria the routes smoke still reports UNCOVERED. They wait
                  on a `boss` listener that does not exist — the test drive fakes it with a
                  button (RI-66). **This is the largest single hole in the product.**
    ⚠ stranded    `Routes.StepR` is defined (`routes.lua:1288`) and smoke-tested three ways, with
                  no product caller. `manager.lua:588` names it as the standing case.

### Analyst (reconciliation — docs against code)

`Reconcile_inbox.md`: **68 items, 55 drained, 13 open.** `ANALYST_LOG.md` carries a row for every
drained one. Acceptance across 31 docs: **0 contradictions**, 128 rows stating no status, 10 stated
but unjoinable, 40 in the queue.

    ☐ RI-85       a question from the bench, unanswered since 2026-08-27: should a `MUTATION:`
                  line carry the fixture condition that makes it observable? ⚠ It took a SIXTH
                  instance on the last working day. This was the live one.
    ☐ RI-88       14 of 19 divergences between `driver_walk_acceptance.md` and `walk.py` carry
                  `file:line` evidence and were never independently checked — *"a work list, not
                  established fact."* That doc can never be stamped VERIFIED.
    ☐ RI-86 □2    46 docs name code and carry no `VERIFIED:` stamp. Declined deliberately —
                  *"I am not stamping any of them today, and that is the answer."* ⟶ The freshness
                  QUEUE is 0 because of this, not because of any missing tier.

### Design architect (the model, the grammar, rulings)

`ARCHITECT_LOG.md` runs to **AL-79** (the shutdown record itself); `ARCHITECT_INBOX.md` carries 48
AI items. The last substantive rulings are worth keeping because they are *grammar*, not code:

    AL-76   a node's ARRIVAL is the BASE — named, unnumbered, unauthored. Tabs number 1..N after
            it; 0 stays clear by not being spent.
    AL-77   ordinal 0 is structurally outside the tracker ramp, so the gate that looked owed
            would have re-checked what construction forbids.
    AL-78   the node-wide TRIGGER is a CHARACTERISTIC, offered default Once (Seen). ⚠ Its KEYING
            to `Seen` was explicitly never verified against code.
    AL-79   the preservation package, and the in-client sweep DECLINED to CoA by his word.

### UI specialist (tokens, renders, the pane surface)

`UI_INBOX.md`: UI-1/UI-2/UI-3 resolved into `UI_LOG.md`; **UI-4 superseded by UI-5** (its
measurements stand, its conclusion does not); UI-5 is a hand-off on the AceGUI lifecycle, measured
end to end, asking for one law. **That law was never ruled.**

### The other benches

    Class_design      Necromancer (Animation — his main) and Reaper (Domination) both SEEDED to
                      `Class_design/<Class>/FINDINGS.md`. ⚠ Crypt Swarm × positive haste is
                      REOPENED — the original test was invalidated by a community-confirmed bug
                      (Scourge Disciple applies NEGATIVE haste, a trap talent).
    Class_identity    Necromancer's identity written (Forsaken, she). Creative lane — feel and
                      story, no mechanical claims.
    Aura              two corpus patterns live-proven in game (summon-count and minion-count
                      trackers) plus findings #14–20. See `operations/STATE.md`.
    Macros            the CoA macro surface mapped: sourced commands, probed conditionals, and
                      the finding that the parser fails SILENTLY.
    Suno              class identities turned into music. Resident in `Class_identity/Suno/`.

---

## 4 · THE GAPS THAT WILL NEVER CLOSE, and why each is honest

    the boss listener      A6.1/A6.2 need a real one; the test drive fakes it with a button.
    `note`'s NoteID        needs a ROW-notes side table. `Store.NoteTable()` is the PERSONAL
                           plane (RI-10) — there was never anything to key into.
    `say`'s SUBJECT        selectable from creature names only once the capture is enriched with
                           segment pulling. A `say` arg is the CALL alone — a complete address,
                           not a half-built one.
    the CONTESTED row      `driver_manager_acceptance.md:460`. The row wants `Set(N)` absolute;
                           the shipped code refuses a stage the route does not hold and a passing
                           smoke asserts it. **Both positions have a reason. No ruling exists
                           either way, and none is coming** — it was Battlewrath's call.
    the in-client sweep    DECLINED, on his word: *"I'd leave the in-client side to CoA. As they
                           have the back end to export."* Not an omission — a boundary.

★ **Every one of these was NAMED rather than designed around.** That was the house rule
(`trace-what-we-know`), and it is why the holes are legible now instead of being discovered by
whoever opens this next.

---

## 5 · IF SOMEONE PICKS THIS UP

The archive at `F:/Projects_games/COA_preservation_2026-09/` holds the full-history bundle through
§758, the works tree, a 254-addon corpus, WTF/SavedVariables (the fact basis), and a complete client
restore point — `Data` whole plus binaries including `Extensions.dll`, 44 GiB. `MANIFEST.md` there
is the entry point, and it was written for exactly this reader.

**Anything left unmeasured can still be measured**, against the archived client, by whoever stands
one up. That was the explicit reasoning behind declining the final sweep: the client is preserved,
so the measurement is deferred rather than lost.

⚠ **What NOT to do.** Do not open `Reconcile_inbox.md`, `ARCHITECT_INBOX.md` or `UI_INBOX.md` and
start draining them — they are a record of a finished conversation, not a queue. Do not read the
acceptance docs' 128 unstated rows as a worklist; a row earned a status on TOUCH, and nothing will
touch them again. **The documents are honest about the day they were written and about nothing
after it.**

---

## 6 · WHAT WAS WORTH LEARNING, and outlives the addon

Kept short on purpose — these are the ones that cost something to find:

    a name is not a use          a name search answers *does this string appear*, never *is this
                                 called*. A tool built on one was 47% wrong about its own bucket.
    the scope protected          an absence is a claim about everywhere you did not look. Five
                                 instances in one day where the SEARCH SCOPE excluded the thing
                                 that would have refuted the claim.
    mutation tests find weak     the yield is bad TESTS, not bad code. The recurring shape:
    TESTS                        **the value under test kept equalling the value it falls back
                                 to** — six instances in the final session alone.
    a stored field isn't live    verify CONSUMPTION, not existence. The last build struck a
                                 control that had written a field nothing read for two days.
    machines do the mechanical   a hand-typed summary is graded by nobody. One printed a struck
    work                         control's name and exited OK; it now reads the declaration.
    emit, don't interpret        emission makes wrong VISIBLE and cheap; interpretation makes it
                                 invisible and expensive.

---

_Closed 2026-08-29. 1663 commits, 59 planning documents, 16 proven checkers, 8 addons, and one
route that never got driven on a live realm._
