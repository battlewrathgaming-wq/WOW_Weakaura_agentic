# RECONCILE AUDIT — the governing set against `driver_architecture.md` §0–§4c (+ §6)

_Analyst (Opus 5), 2026-08-21, at Battlewrath's ask: **"Reconcile the governing docs against
driver_architecture.md §0–§4c… Multi-agent operation. No in-line editing until we know what needs
editing."** Stored before any implementation work, at his instruction._

⚠⚠ **THIS FILE RULES NOTHING AND EDITS NOTHING.** It is the finding set. Every row names what it
checked, on both sides, with a citation. **55 findings; 7 read-only audits; nothing was edited to
produce it.** Agents were `Explore` type — structurally unable to write — so "no in-line editing"
was enforced by the tool rather than by instruction.

★ **METHOD.** Seven parallel read-only passes: §0–§2 · §3a producer · §3b/§3c consumer · §4
principle · §4b/§4c order of effects and the reader's first run · a staleness/values pass on three
axes · and §6's CLOSED gaps. The seventh was added mid-run because the third proved one closure
false, which made the rest untrustworthy unverified.

⚠ **CONFIDENCE is per finding.** HIGH = the agent read BOTH sides in source. LOW = inferred, or
the severity rather than the fact is uncertain. Nothing here should be actioned without re-reading
its citation — the audit's own scope is a claim about where it looked.

---

## THE DIRECTION RULE, which decides what moves

`driver_architecture.md` §7: *"registered in `DRIVER_BASIS.md` as **#0 — the macro model**; it
carries no mechanics, so where it seems to disagree with a lower doc the mechanics doc is right and
THIS file has drifted — report it."*

⟶ But a NEW RULING taken with Battlewrath (`ARCHITECT_LOG.md` AL-1..AL-8) supersedes older
governing text wherever it sits. **Authority follows the ruling's date and author, not the file.**

    A  ARCHITECTURE CORRECTION   the macro doc lost a distinction -> the architecture file changes
    B  GOVERNING BEHIND HEADING  an accepted ruling the governing doc has not caught -> date it
    C  FALSE CLOSURE             a §6 gap marked closed that is open
    D  UNBUILT                   the heading is right, nothing implements it -> a line item
    E  STALE VALUE / LIVE DEFECT the number or the code is wrong
    F  BATTLEWRATH'S WORD        two of his rulings disagree, or the cost is his to accept

---

# E-0 · THE ROWS ARE NOT WIRED YET — ⚠⚠ RECLASSIFIED, AND THE ANALYST'S FRAMING WAS WRONG

⚠⚠ **THIS WAS FILED AS "THE ONE THAT OUTRANKS THE REST" AND IT IS NOT A FINDING AT ALL.**
Battlewrath, 2026-08-21, on being shown it:

> *"This is known. We're still in development and this has yet to be wired in. Interface work is
> needed first onto the ace method, fixing the style / grammer to be WA coded. And then giving each
> a settled home."*

★ **THE MEASUREMENT BELOW STANDS; THE SEVERITY WAS THE ANALYST'S AND WAS NOT HIS TO SET.** Zero
rows is the expected state of a build that has not reached the wiring step, and the record already
said so from two directions — §3a marks the node editor **◐ DIVERGENT** and A10.3 is named as the
replacement pane. ⟶ It is a **SEQUENCE POSITION**, not a disconnect.

⚠ The fault is a familiar one: a true measurement extended one step into a judgement about
priority. *"The two halves of the product do not connect"* was literally true of the code and
false about the project.

### ⟶ HIS BUILD ORDER FOR IT, recorded because it is new and it sequences section D

    1  INTERFACE WORK onto the ACE METHOD
    2  the STYLE / GRAMMAR fixed to be WA CODED
    3  each given a SETTLED HOME
    4  (then) the rows wire

✅ **STEP 2 DEFINED BY BATTLEWRATH, 2026-08-21** — the Analyst flagged the term as undefined and
declined to infer it; he pinned it the same turn:

> *"Coded in the generic sense. Not using their code. But the tabs, tone, ace computed padding.
> And the universal pane with fold in / fold out. Tab in tab displays. (Tab: Object options :
> Beacon/child : Tab 1 action tab 2 action (Building new tab as choice, rather than limited tabs.
> Like WA 'Trigger 1' drop down 'add trigger' trigger 2)"*

    NOT          WeakAuras' code. The IDIOM, generically — nothing is imported or copied.
    THE IDIOM    tabs · tone · **Ace COMPUTED padding** (the layout computes it; not hand-placed
                 `SetPoint` offsets, which is what `object.lua` does today)
    THE PANE     ONE universal pane, with FOLD IN / FOLD OUT
    THE NESTING  TAB IN TAB:

                     Tab: Object options
                       └ Beacon / child
                           ├ Tab 1   action
                           └ Tab 2   action

    ★★ THE RULE  **tabs are ADDED BY CHOICE, not a fixed set.** WA's shape is the reference —
                 *"Trigger 1"* → *"add trigger"* → *"Trigger 2"* — but **NOT its word.**

    ⚠⚠ OURS IS   **Action 1 · add action · Action 2** (Battlewrath, 2026-08-21:
                 *"Trigger has meaning. So Action 1, add action, action 2."*)
                 ★ `Trigger` is ALREADY OURS and means something else: a NODE field, One time ·
                 Every time, not built and with no code term chosen (`contract.lua:87-90` —
                 *"a NODE field, not a row field"*). Borrowing WA's label for a ROW-level tab
                 would collide with a node-level control we have already named.
                 ⟶ The naming law doing its job: the shape transfers, the vocabulary does not.

### ★★★ AND THIS IS THE MISSING HALF OF E-0, NOT A SEPARATE SUBJECT

The model rules *"N BEHAVIOUR records, one per action tab"* and §B P3b measured that the pane has
**no tab concept at all** — one `object.sense`, one `object.role`, one `object.action`, no strip, no
index, no add control. ⟶ **A dynamic tab strip is exactly what produces N rows.** So E-0's "zero
rows" and P3b's "no tabs" are one thing seen from two ends, and step 2 is where it is fixed.

★ **CORROBORATION, not invention:** `Routes.SetRow(b, child, index, sense, action, arg, offered)`
already takes an **index** — the setter was built for a numbered, variable-length tab set and has
been waiting for the surface. A fixed pane would never have needed the argument. ⟶ The consumer
side needs no change and neither does the setter; what is owed is the surface and its caller.

⚠ **Where it lands is A10.3's acceptance (the Analyst's), NOT this file** — recorded here because
this is where the gap was flagged, and it moves on the architect's response per his order.

### THE MEASUREMENT, which is what the bench needs

**THE AUTHORING SURFACE PRODUCES ZERO ROWS AND THE CONSUMER READS ONLY ROWS.**

    WHAT IS      `object.lua` never calls `Routes.SetRow`. It writes the flat pre-row shape:
                 `SetChildSense` (:921) · `SetChildRole` (:981) · `SetChildAction` (:1077).
                 `Routes.SetRow` has NO product caller — test-only (`emit_built_state.py`).
    AND          `bucket.lua:207-221` iterates `Routes.RowsOf(c)` with NO fallback to
                 `c.sense` / `c.action`.
    SO           a node authored today reaches the bucket with an EMPTY ROW LIST and arms with
                 NO BEHAVIOUR AT ALL.
    NOT          "one row that the tab model will later multiply" — that is what §3a's row says
                 and it understates it. Zero.
    CONFIDENCE   HIGH

⟶ So the wiring owed is exact: `object.lua` moves from the three flat setters to `Routes.SetRow`,
and `SetRow` gains its first product caller. ★ **Value of the measurement, now that it is not an
alarm:** it names precisely what step 4 has to do, and it says the consumer side needs no change —
`bucket.lua` already reads the shape the model rules. ⚠ D1 stays in section D as a line item; it is
not a blocker on anything before it in his order.

---

# A · ARCHITECTURE CORRECTION — the macro doc lost a distinction

_These are for the Design architect. The mechanics doc is right in each case._

    A1  §2 calls `MapID:RID:BID:CID : Stage : Step` "THE GATE".
        AGAINST  model §A1.4a, Battlewrath verbatim: the four-part prefix `MapID:RID:Stage:Step`
                 is the bounce; `BID:CID` are IDENTITY, admitted not tested. `driver.lua:112`:
                 *"the bounce is four parts and the step is the fourth"*.
        IMPACT   as written a builder implements a bounce on `BID:CID`. Separate the label into
                 the ADDRESS and the GATE. Nothing below changes.       HIGH

    A2  §2 "anyone's PROGRESS (the cursor lives in the SENSOR, not the record)".
        AGAINST  `sensor.lua:120` — the armed object is `{nodes, inSet}`, no cursor. The cursor is
                 the manager's by AL-2, and §3b/§4b in the SAME FILE say so.
        IMPACT   a §2 <-> §3b/§4b contradiction inside one governing doc. The surviving claim is
                 only "progress never travels". ⚠ The Analyst repeated this error in A12.9a.  HIGH

    A3  §4 "the GATE is an index built at load, never a test at runtime".
        AGAINST  model §A1.4a: *"⚠⚠ IT IS NOT `Rule.Gate` … Two gates, different operands, both
                 named 'gate' — written down here so the next reader does not merge them."*
                 `Rule.Gate` IS a per-node per-sample runtime test (`rule.lua:89,127`).
        IMPACT   §4 merges the prefix bounce with the rule's mapID gate — the doc it summarises
                 is the one carrying the warning against that merge.      HIGH

    A4  §4 "a child without an ordinal is an UPDATE type (ALWAYS LIVE)".
        AGAINST  model §A1 4a: *"THE TWO ZEROS ARE DIFFERENT"* — STAGE 0 = always eligible;
                 STEP 0 = the pass-through WITHIN its stage. `bucket.lua:326-332` arms `byStep[0]`
                 only when that stage is current.
        IMPACT   borrows stage 0's property for step 0 — read literally it arms every stage's
                 satellites at once.                                      HIGH

    A5  §4 "the STAGE completes when TOLD (a Next)".
        AGAINST  A2.8: *"a node's NEXT = **Stage / Set(N)** fires"*. A Next of type **Step** never
                 completes a stage. §4b step 5 says it correctly TWENTY LINES BELOW.
        IMPACT   makes all three Next types stage-terminal, including the default.   HIGH

    A6  §4b step 5 "Stage -> +1".
        AGAINST  L3 *"expose a gap, never renumber"* — stages 1,2,5 are authorable. `+1` arms
                 stage 3, which `Bucket.Stage` resolves to bucket 0 alone.
        IMPACT   ⚠⚠ **THE RUN STALLS WITH ONLY RECOVERY ARMED.** Should read "the next positive
                 stage PRESENT". A defect in the accepted spec, not doc drift.
                 ⚠ A12.5a silently paraphrased this instead of reporting it — the Analyst's
                 fault, against A12's own preamble.                       HIGH

    A7  §4 "no duplicates BY CONSTRUCTION", stated flat with no status marker.
        AGAINST  both halves unbuilt — see C1.
        IMPACT   §4 reads as a shipped guarantee. §3's rows carry status marks; §4 should too. HIGH

    A8  §0 exists "so each can self-reference".
        AGAINST  `operations/PROTOCOL.md:22`: *"Role is INFERRED from the live chat… A self-label
                 in a shared file is NOT self-verifying"*, with an origin note recording a thread
                 that mis-read its own file-borne label as proof of identity.
        IMPACT   §0 becomes a table of DUTIES cited by a thread that already knows its role from
                 the human. ⚠ SIDE FINDING, operational: `boot.py` ALIASES carries no `analyst`
                 and no `architect` lane — two of four seats cannot run the mandated boot.  HIGH

    A9  §3a Node editor: "⚠ writes ONE row".
        AGAINST  E-0 above — it writes ZERO.                              HIGH

    A10 §3a Personal-note plane marked ✗.
        AGAINST  shipped end to end: `store.lua:489` `NoteTable` · `routes.lua:1934-1962`
                 `NotePlane`/`GetNotes`/`AddNote`/`NoteCount` · `:627` `DeleteNote` ·
                 `promoter.lua:389` draws it as a map layer. Genuinely missing: only the PER-ROLE
                 dimension and the dedicated pane (ruled OUT by A10.6).
        IMPACT   a whole shipped data plane reads as not built, so nothing schedules its debt. HIGH

    A11 §3a Map must-never cites `map.lua:46` for "MAP xy where WORLD is meant".
        AGAINST  `map.lua:45-59` is two MAP-space sizes (1002x668 vs 4x3x256 tiles) — it says
                 nothing about world coordinates. The real boundary is `routes.lua:484-492`
                 (`Routes.Place` -> `Calibrate.ToWorld`, world pair left ABSENT when uncalibrated).
        IMPACT   points the reader at the wrong hazard; the real guard is uncited in §3a.
                 ⚠ The must-never itself is NOT violated.                 HIGH

    A12 §3b Sensor marked ✓ owning "the in-set AND THE PREVIOUS in-set … returns changed nodes by
        address WITH the transition word".
        AGAINST  `sensor.lua:120` one `inSet`; `:189` overwrites in place; `Poll` returns the
                 currently-INSIDE snapshots, not changed, not by address, with no transition word
                 (`Rule.Evaluate`'s second return is discarded at `:188`).
                 ⚠ AND `snapshot()` (`:107-116`) DROPS `rows` — the armed object physically has no
                 tabs to attach a transition word to.
        IMPACT   three of five things the row claims are absent; status is ◐ not ✓.  HIGH

    A13 §3b Readout ◐ is generous — "per target its first hit" has no implementation (`firstHit`
        greps to zero); only the IN-set half exists, and by node table rather than by address.
        IMPACT   ✗ would be defensible.                                   LOW (severity)

    A14 §3c cite `COA_Landmarks/… sensor.lua:36-43` dangles — that addon has no `sensor.lua`.
        Intended target is `COA_DungeonRun/sensor.lua:36-42`.             LOW (severity)

    A15 §4b step 4 "say -> chat" sits ten lines from §4c 6 "the manager EMITS — NEVER IN CHAT",
        with no distinguishing clause. Not a true collision (an authored `say` tab is the author's
        channel) but nothing says so, and `say` has no code word to anchor the reading.   LOW

    A16 §4b step 9 "arming again lands the reader by recovery" is stated unconditionally; nothing
        requires a route to carry a stage-0 beacon (`bucket.lua:75-96` refuses only for no beacons,
        wrong map, fractional stage). ⚠ A12.7a assumes one exists too.    LOW

---

# B · GOVERNING DOC BEHIND THE HEADING — date it, cite the ruling

    B1  A2.10a still quotes §81 as LIVE LAW — *"duplicate stages, out-of-order and fractions are
        all legal, the author is TOLD"* — as the derivation for store-and-tell.
        ⚠ TWO of its three examples are now false IN THE SAME FILE: duplicates (A2.10 / AL-4) and
        fractional beacon stages (§A3 row 9, `bucket.lua:64-66` a named refusal). 450 lines from
        the row that supersedes it. `:59-61` shows the correct treatment — A2.3 struck and dated.
        -> narrow the §81 citation to "out-of-order", dated 2026-08-21.   HIGH

    B2  A11.9a still permits a stage-0 beacon to write the arrow — *"a node's action tabs may set
        one (`supertrack`)"*, no tray-0 exemption. AL-6 (one day later) rules RECOVERY NEVER USES
        THE SUPERTRACKER. A12.3c already carries it; A11.9 is the only doc behind.   HIGH

    B3  A10.5a and A10.7 step 8 still carry `hit · skip · false_advances`. ⚠ STALE TWICE OVER:
        A11.5a already ruled skip/false_advances stage-level and V2-only, and its REVIEW LOG
        recorded the correction. V1's readout is the per-sample IN set + per-target first-hit. HIGH

    B4  A10.5 has NO reader-side counterpart — no note pane, no collapse, no author/reader split.
        AL-7's two panes are ruled ONLY in the architecture file. A12's WHAT IS OUT calls the
        counterpart "owed".                                               HIGH

    B5  A11.x carries no row for the sensor's RETURN CONTRACT (changed set + transition word). The
        only statement of it lives in `driver_sensor_brief.md`, which "rules nothing", and in A12.
        -> A11.3 gains the row, dated to AL-2, or the sensor gets built to the in-set contract. HIGH

    B6  `driver_data_model.md` seed S3 (*"WHO RESOLVES NAMES for a human-facing readout"*) is still
        listed open; architecture G11 records it CLOSED by §4c 5. Row 6 already agrees.  MEDIUM

    B7  §A6's RUNTIME tier scopes what is OWED to "the bucket item and the armed snapshot" only.
        §4b invented three more pieces of state the day after — the manager's cursor, its ledger,
        and the one saved slot — and none is in any tier.                 MEDIUM

    B8  `DRIVER_BASIS.md:349` lists RI-22 as still open; it DRAINED 2026-08-20. `:477` guards
        itself (*"DERIVE from the item stamps"*), `:349` does not.        LOW

    B9  RI-42 states RI-38 closed; RI-38's own section carries no DRAINED stamp. The inbox
        disagrees with itself, and §6 G1 copied the older side.           HIGH

    B10 A12.2a conflates the offer with the build outcome — a build refusal cannot un-offer a route
        already offered by map. Should end "or this is the Active Route". (Analyst's own row.) MED

    B11 A12 claims to grade §4b's ten steps; **step 0** (map-filtered offer, the single pick) and
        the **When-off half of step 4** (listener disarm) are ungraded. Both have code to grade:
        `routes.lua:335` `Routes.List(mapID)`, `bucket.lua:87-90`. (Analyst's own.)   HIGH

---

# C · FALSE CLOSURES in §6

    C1  G6 "CLOSED by R7 -> cannot be authored".
        ⚠⚠ FALSE AT BOTH ENDS TODAY. The picker A10.3e is ✗ and three doors still accept a second
        (`promoter.lua:530` · `routes.lua:432` · `routes.lua:1483`). AL-8's answer was that the
        BUCKET refuses — and the agent READ the refusal list: **fourteen named refusals, none for a
        duplicate stage.** AL-8's own words are *"its NEXT named refusal"* — owed, not built.
        IMPACT   the manager's acceptance is written on a precondition enforced nowhere; an older
                 or imported route with two beacons at stage N reaches the runtime silently.
                 ★ A12.2b is correct (marked ⚠⚠ OWED); §6 and §4 read as shipped.   HIGH

    C2  G18 "CLOSED -> the sensor keeps the previous in-set and returns the transition word".
        ⚠⚠ CIRCULAR at three hops, zero code. §3b cites `sensor.lua`; the code does neither;
        RI-42's own IMPACT block lists *"sensor.lua (previous in-set; transition word)"* as work
        STILL OWED in the same item whose closing list says G18 is done. The struck-through
        ORIGINAL G18 text is a literally accurate description of the shipped file.
        IMPACT   the whole sense vocabulary is unimplementable from what the sensor keeps, and
                 four places now say it is done.                          HIGH

    C3  G19 "CLOSED -> re-arm IS the bucket swap".
        The re-arm half is real. The struck text's SECOND half — *"the in-set's semantics once
        armed ≠ eligible"* — is answered nowhere. `sensor.lua`'s header still calls the two sets
        OWED; the sensor brief's G5 still asks it.
        ★ A NEW FAULT SHAPE: **a multi-part gap struck on a citation answering only part of it.**
        The strikethrough hides what survived. G3 has it too.             HIGH

    C4  G4's zone-change ruling exists ONLY as struck text inside §6, with NO citation. Repo-wide
        grep for *"highest identity"* returns ONE hit — the gap line itself. §7 rules that answers
        land in the doc that owns the part, **never here**.
        IMPACT   the ruling disappears when §6 is drained. Same class as a ruling stranded in an
                 ARCHIVE file: a live decision where nothing reads for authority.   HIGH

✓ **Thirteen closures followed and found genuinely closed** (G2 · G5 · G7 · G9 · G10 · G11 · G12 ·
G13 · G21 · G26 · G14 retired · G4's reload half · G1's design half). **Six open gaps checked for
the inverse fault — none already answered.**

---

# D · UNBUILT — the heading is right, nothing implements it

_These are development line items, not disagreements._

    D1  THE ROWS DO NOT FLOW (E-0). The pane writes the flat shape; the bucket reads rows only.
    D2  THE SENSOR KEEPS NO PREVIOUS IN-SET and returns no transition word; `snapshot()` drops
        `rows`. Blocks the whole sense vocabulary and §4b step 4's dispatch.
    D3  THE DUPLICATE-STAGE REFUSAL is absent from `Bucket.Build`'s fourteen. (C1)
    D4  THREE OF FOUR DISPATCH VERBS have neither an authoring door nor a callable — the action
        set is `nothing | supertrack`; `adaptor.lua` has no word for `note`, `say` or `boss`;
        `Bucket.Resolve = nil`, so nothing binds an action word to a callable.
    D5  NO SAVED SELECTION SLOT — `store.lua` has only the per-character `ui` kv. ⚠ Its natural
        home already exists and is already one-record-overwritten in shape (`store.lua:521-536`);
        when it lands, `:506`'s "Session-only UI state" comment is wrong and moves with it.
    D6  THE ROUTE MANAGER does not exist — no `Manager` symbol anywhere.
    D7  THE PICKERS (A10.3e) are ✗; stage and ordinal are free-text edit boxes with no floor and
        no clamp (`Routes.SetChildReach` accepts negatives).
    D8  THE COMPLETION LEDGER, the CLEU listener, the tracker escapement's wiring, the import
        door, the flattener/exporter, the test-drive remote — all ✗, all correctly marked.
    D9  `Sensor.Sample` is CALLED AND DEFINED NOWHERE — position acquisition is an unwired seam.

---

# E · STALE VALUES AND LIVE DEFECTS

    E1  ⚠⚠ **A LIVE DEFECT.** `capture.lua:159` — `(z or 0) - (pin.z or 0)` invents an altitude
        inside a recorded distance, written to the record as `od`. The guard four lines up checks
        `x and pin.x` and NOT `z`. ★ The comment directly above REFUSES this exact pattern:
        *"A distance to a point nobody is tracking is arithmetic, not a second term — and it would
        sit in the record looking exactly like a good one."*
        -> guard by SELECTION: refuse the pair, as `Rule.Usable` does.    HIGH

    E2  FOUR `b.stage or 0` READ SITES survive the fix `rule.lua:48` headstones —
        `routes.lua:379` · `:1805` · `:1853` · `:1862`. Most load-bearing is `Routes.BeaconAt`:
        `if (b.stage or 0) >= (index or 0) then return b end` — **a stageless beacon reads as
        stage 0 and is returned at index 0**, the same "a node not in the sequence acts as though
        it is" shape A2.10a exists to refuse.        HIGH on the pattern, LOW on reachability today

    E3  `routes.lua:1512-1513` tells the next reader the band default *"lands as an `or` on this
        line and it will be the ONLY place it lives"*. It landed at `bucket.lua:198`. All three of
        its clauses are stale (the band IS ruled; it is NOT `±`; it is not on that line). The first
        sentence — `ReachOf` returns raw nil — survives.                  HIGH

    E4  `DRIVER_BASIS.md:114` says `band/radii = raw nil + consumer resolves **±2.5**` — two-sided,
        retired by RI-22.                                                 HIGH

    E5  `driver_programmatic_model.md:426` says `±2.5` AND *"the default radii apply when the
        author sets nothing"* — ⚠ **there is no radius default at all**; `bucket.lua:179-181`
        REFUSES a child with no radius. The doc promises a fallback the code deliberately lacks. HIGH

    E6  `driver_analysis_asklist.md:649` asserts `POLL_MAX 2 s` as the live rate with NO RI-34
        correction block, while five neighbouring stale figures in the same file all carry one.
        The arithmetic that follows it is wrong by 2x.                    HIGH

    E7  `dungeonrun_model.md:927` names `bandDown` as a live field; it is RETIRED, not unused
        (`routes.lua:1468`, and `DropRetired` nulls a stored one).        HIGH

    E8  ⚠⚠ **`driver_walk_acceptance.md` W3.2 ships `bandDown` as a constant** — *"Ships as two
        constants (`bandUp`, `bandDown` defaults)"*; `:16` lists it as a route input; W1.7 tests
        `[−bandDown, +bandUp]` and *"Band OPEN fires"*. **And `walk.py` still implements all of
        it** (`band_down` throughout, `OPEN = float("inf")`).
        ★★★ **DOC AND DESK-CODE AGREE WITH EACH OTHER AND BOTH DISAGREE WITH THE RULING — a grep
        of the docs alone will not catch it.**
        ⚠⚠ AND THE ANALYST'S OWN TOOL MADE IT INVISIBLE: `check_retired.py`'s HOME table excludes
        `bandDown` from the walk brief on the argument that the desk owns band terms. **RI-22
        removed the downward half EVERYWHERE, not just driver-side.** The exclusion did not fail
        to find it — it made it unfindable.                               HIGH

    E9  `driver_authoring_acceptance.md:736` describes the `Rule.OPEN` defect in the PRESENT TENSE;
        `Rule.OPEN` no longer exists and the defect closed by removal.     LOW (may be a record)

✓ **All six settled values verified correct in code**: `sensor.lua:43-45` = `0.1 / 1.0 / 100` ·
`walk.py:490` `TELEPORT_VMAX = 100.0` · `bucket.lua:35` `BAND_DEFAULT = 2.5`.
✓ **`math.huge` survives in exactly two places** (`rule.lua:76`, `bucket.lua:57`) and both are
REJECTION TESTS, never values — no infinity is produced or handed onward. Satisfies the rule.
✓ **`landmark_design.md`'s 0.20 / 30 / 2.00 are CORRECT** — a different product. Do not "fix".

---

# F · NEEDS BATTLEWRATH'S WORD

    F1  ★★★ **R2 AND RI-23 POINT OPPOSITE WAYS, TWO DAYS APART, BOTH HIS.**
        R2 (2026-08-21): every record opens with the gate — `MapID:RID:BID:CID:stage:step`.
        The BEHAVIOUR record today is `MapID:RID:BID:CID : Sense : action : arg` — no Stage, no
        Step. ⚠ Model rows 3 and 4 argue AGAINST adding them: *"NODE FIELDS APPEAR ONCE. Eleven
        fields previously repeated per row and could disagree with themselves"* — RI-23
        (2026-08-19) retiring per-row repetition.
        COST     `Contract.BEHAVIOUR` gains two fields; `smoke_contract` and every fixture row move.
        ⟶ Not the Analyst's to resolve.

    F2  C1 — the manager is being written on a guarantee enforced nowhere. Accept the window, or
        sequence the refusal before the manager?

    F3  ✅ ANSWERED 2026-08-21 BY BATTLEWRATH DIRECTLY, before it reached the architect.
        ~~Does E-0 reorder the build?~~ **NO — it is known and expected.** Interface work onto
        the Ace method first, then the style/grammar to be WA coded, then a settled home for
        each, then the rows wire. See E-0 above, reclassified.

---

---

# G · THE DEVELOPMENT LINE ITEMS — ⚠ MOVED OUT OF THIS FILE 2026-08-21

⟶ **They are in `Reconcile_inbox.md` as RI-44, and that is where they belong.** Battlewrath:
*"I'd push it into the inbox. I'm trying to keep decisions / discussion isolate so that the docs
don't keep shifting."*

★ **The line this draws, and it is a good one:** an audit RECORDS what was found; a PLAN proposes
what to do about it. The first is settled the moment it is measured; the second is discussion until
he rules on it. ⚠ The Analyst also put a pointer in `DRIVER_BASIS.md` — **the entry document moving
for something undecided, which is exactly the shifting he is guarding against.** Removed with it.

_How to keep this true: it is a RECORD of one day's reading, not a live check. Re-run the passes
rather than trusting it, and re-read a citation before acting on its row. ⚠ Its own scope is a
claim about where seven agents looked — E8 is the standing proof that an exclusion can make a real
finding unfindable._
