# STALENESS AUDIT — the planning docs against the code, 2026-08-21

_Analyst (Opus 5), at Battlewrath's ask: **"And a staleness sub agent audit."** Four parallel
read-only agents (`Explore` type — structurally unable to write), one axis each. **Nothing was
edited to produce this file.**_

⚠⚠ **THIS FILE RULES NOTHING.** It is the finding set. Corrections made FROM it are listed at the
bottom with what was left alone and why. Every row is re-runnable at its cite.

    AXIS 1   claims of NOT BUILT / OWED where the code now has it
    AXIS 2   claims of BUILT / LANDED / CLOSED where the code no longer matches, and GHOST
             `grades` citations naming functions that do not exist
    AXIS 3   `file.lua:N` citations that point at the wrong line
    AXIS 4   numbers, constants, enumerated lists and counts

---

## ★★★ THE HEADLINE, and it is not any single row

**The docs did not drift because anyone was careless. They drifted because three of the four axes
are things a document CANNOT keep true about itself.** A build-status claim is a claim about a
file that moves; a line number is a pointer nobody owns; a count is a snapshot. ⟶ Every one of
them decays the moment it is typed, and **the planning set is what every agent reads at boot.**

★ **The one axis that came back clean is the one a machine already guards.** All **39** `grades`
citations resolve to real functions — because `emit_built_state.py` refuses to emit when one does
not. ⟶ **Zero ghosts, against ~31 drifted line numbers in the same documents.** That is the whole
argument for a guard over a convention, measured on one afternoon.

---

## ⚠⚠ THE FINDING THAT IS NOT A DOC FAULT AT ALL — the source lied

**Four planning documents call `AddBeacon forces a stage` a live precondition.** It is not: S7
(§395) landed and `0` is the stageless request. But the docs were quoting faithfully:

    routes.lua:474   ⚠ ALWAYS A STAGE. See SetStage's note: the stageless RECOVERY beacon has no
    routes.lua:475     path in through here either. Owed, no impact yet.
    routes.lua:476   ★★★ S7 (§395): 0 IS THE STAGELESS REQUEST, and it is not a new vocabulary -
    routes.lua:491       if want == 0 then b.stage = nil    -- the recovery beacon: no stage

★★ **THE DEAD COMMENT SITS DIRECTLY ABOVE ITS OWN REPLACEMENT, IN THE SAME BLOCK.** ⟶ *The doc
quoted faithfully; the source lied* — which is the one failure mode **"the source is truth" cannot
catch**, and it propagated to four places because each author did the right thing.

⟶ **This is [[half-formed-code-invites-building-on-it]] applied to COMMENTS**, and it earns the
same rule: a superseded comment is REMOVED, not left above the thing that supersedes it.
⬜ **The comment is the bench's to remove.** The four doc citations are corrected below.

---

## AXIS 1 + 2 · BUILD STATUS — what the docs say is missing and is not

| doc | claim | code |
|---|---|---|
| `driver_manager_acceptance.md` preamble | **"NOTHING HERE IS BUILT"** · "no row carries a `grades` line for a manager function — inventing one would name an identifier that does not exist" | `manager.lua` §461, **16 `Manager.*` functions**, in the `.toc`, its own header naming this brief |
| `DRIVER_BASIS.md` | "NOTHING IN IT IS BUILT… the identifiers do not exist yet" | same |
| `driver_architecture.md` §3b Sensor row | "TODAY: one in-set · `Poll` returns the currently-inside snapshots (not changed, not by address) · `snapshot()` DROPS `rows`" + the whole **OWED** half | `Sensor.Arm` allocates **four** sets · `Poll` swaps them and returns `changed` = `{address, word, node}` · emits `WHEN_ON` / `SEEN` / `WHEN_OFF` · `snapshot()` carries `rows` |
| `driver_architecture.md` §6 G18 | "**ZERO code behind it today**; until it lands the sense vocabulary is unimplementable" | built |
| `driver_architecture.md` §6 G19b | "`sensor.lua`'s header still calls it owed" | the word `owed` **does not occur in `sensor.lua`** — the cited evidence is gone |
| `driver_sense_acceptance.md` A11.3e | "**NOT BUILT**" (three clauses) | every clause false |
| `driver_manager_acceptance.md` A12.2f | "**NOT BUILT:** `Bucket.Build` has no orphan check (grep for `orphan` returns nothing)" | `bucket.lua` headed *"A12.2f · NO SILENT ORPHAN"*; **the row's own suggested grep now hits** |
| `driver_manager_acceptance.md` A12.2b | "⚠ **OWED** … **BENCH'S TO BUILD**" | `bucket.lua` refuses *"two beacons at stage %s … re-slot in the editor"* |
| `driver_authoring_acceptance.md` A8.1 | "`Routes.StageOf` … **does not exist**" | built §329, corrected §330 |
| `driver_authoring_acceptance.md` A2.11 | "there is no `NextOrdinal` and no ordinal gap function anywhere (**`grep` returns nothing**)" | `Routes.NextOrdinal` and `Routes.OrdinalGaps`, and `routes.lua` names A2.11 at the block head |
| `driver_authoring_acceptance.md` A2.12 | "`SetChildFireOn` … has no caller" | **removed whole** §392; a headstone stands where it was |

★★ **THE SEVERITY IS NOT UNIFORM, AND ONE OF THESE IS DIFFERENT IN KIND.** A11.3e is **L2.3 —
Chain 2's *"BLOCKS ALL DISPATCH"* item.** The bench reported Chain 2 complete and the acceptance
never caught up, so the document a cold reader consults still said the sense vocabulary was
uncomputable. ⟶ **A stale BLOCKER is worse than a stale fact: it stops work that is already
unblocked.**

⚠ And three of these rows told the reader the exact grep that would refute them. **A claim that
ships its own falsification test and is never run is the cheapest audit nobody performed.**

---

## AXIS 3 · CITATIONS — ~31 of ~55 drifted, 56%

⚠⚠ **NOT FIXED BY HAND, ON PURPOSE.** Re-typing 31 line numbers rebuilds the artifact that just
rotted — [[machines-do-the-mechanical-work]], whose own note records this project doing exactly
that twice. ⟶ **`addons/tools/check_cites.py`** was built instead: it resolves every `file.lua:N`
in `planning/*.md` (**440 today**) and prints what is actually on the line.

    ROTS      routes.lua:1529                a number nothing owns
    HOLDS     routes.lua Routes.Outcome      a symbol the file itself carries
    HOLDS     "no default is invented here"  a unique sentence, greppable

★ **THE FIX IS THE FORM, NOT THE THIRTY-ONE.** ⬜ Converting load-bearing citations to symbols is
a job, not a sweep, and it is named rather than half-done.

⚠ **AND THE TOOL HAD THE FAULT IT EXISTS TO CATCH ON ITS FIRST RUN** — scoped to `COA_DungeonRun`
alone, so 74 citations came back "NO SUCH FILE" that were really *another addon in this repo*. Kept
in its header. **A scope that excluded what would refute it, inside the resolver written because
scopes rot.**

⬜ Two citations are stale **IN CODE**, not in a doc — `rule.lua`'s cite of `routes.lua:1512` and
`routes.lua`'s self-cite of `:566`. **The bench's.**

---

## AXIS 4 · NUMBERS AND COUNTS

    ✅ EVERY THROTTLE AND GEOMETRY CONSTANT MATCHES.  POLL_MIN 0.1 · POLL_MAX 1.0 ·
       MAX_CLOSING_SPEED 100 · TELEPORT_VMAX 100.0 · R_MIN 5 and its derivation 100 x 0.1 / 2 ·
       BAND_DEFAULT 2.5 · NOTE_MAX 200 · the 240 x 600 pane · the layout gaps. ★ These are the
       numbers an argument was BUILT on this week, and they held. The rot is in numbers nobody
       re-derived.
    ✅ EVERY ENUMERATED LIST MATCHES.  SENSE_WORDS · ROW_ACTIONS · ROW_ARG - values, members and
       their cites all exact.

    ⚠ COUNTS DRIFTED, and every one of them upward - a count is written when a list is short.
       fourteen named refusals -> 16      ·  "none for a duplicate stage" -> there is one
       fourteen macro laws     -> 16      ·  §A's "22 selected rows"      -> 27 base + 6 more
       37 controls             -> 36      ·  ReachOf's "one call site"    -> two

### ⚠⚠ TWO THAT ARE NOT COUNTS AND MATTER MORE

**1 · `Store.TierYards` DOES NOT EXIST.** `driver_analysis_asklist.md` carries a formula —
`slack = (dist - Store.TierYards(tier)) / MAX_CLOSING_SPEED` — naming a function that is nowhere in
the repo. The shipped sensor uses the per-node `n.r`. ★ **A ghost identifier inside a formula is
worse than a ghost in prose: it reads as a specification.** ⬜ The Analyst's to correct.

**2 · THE GATE FIGURE DOES NOT RECONCILE.** `Reconcile_inbox.md` RI-51's state block reads
*"122 mutations across nine sets, 0 bad"*. Run today: **`mutate.py dungeonrun` reports 305/324**,
across three spec files. ⚠ **REPORTED, NOT RULED** — "nine sets" may name a grouping the headline
does not print, and the Analyst did not reconstruct what was run. ⟶ **The bench's figure and the
bench's to reconcile**; it is raised because a gate line is quoted forward into every state report.

---

## ✅ WHAT WAS CORRECTED FROM THIS AUDIT, and what was deliberately not

    CORRECTED   the Analyst's own documents - the manager brief's preamble · A12.2f · A11.3e ·
                A8.1 · A2.11 · A2.12 · the four AddBeacon preconditions in the two acceptance
                files · A10.3e's and A10.9f's 714
    FILED       ARCHITECT_INBOX.md AI-7 - `driver_architecture.md` and `DRIVER_BASIS.md` carry
                the same claims and are NOT the Analyst's to edit
    THE BENCH'S the dead `routes.lua` comment · the two in-code stale cites · the gate figure
    NOT DONE    the ~31 drifted line numbers, by hand. `check_cites.py` enumerates them and the
                FORM is the fix.
    NOT DONE    16 `grades` lines for the manager's functions. Each is a claim about which
                function answers a criterion; they need reading, not filling.

## ⚠ WHAT THIS AUDIT DID NOT CHECK — an absence here is not a clean bill

    · PROSE claims with no number, count or status marker attached - the bulk of A2 / A3 / A6
      and most of A10.x were not opened
    · whether each surviving `grades` citation's FUNCTION BODY does what its row describes.
      Existence was proved for all 39; behaviour was read for six.
    · `ARCHIVE__dungeonrun_poc.md`, `planning/history/`, `planning/reference/` - records
    · ~200 further `*.lua:N` citations outside the six priority docs. ★ The sample that WAS
      checked drifted at 56%, so that population is likely worse, not better.
    · the 230-addon census - its corpus is the game client, outside this repo. Internally
      consistent; NOT re-runnable here.
