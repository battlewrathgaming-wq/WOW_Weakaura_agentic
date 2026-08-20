# THE DATA MODEL — THE HEADING

_Opus 5 (Analyst), 2026-08-19, at Battlewrath's ask: **"We need a heading fixed-ish on our data
model before we over build selections... Then we can retire the material in reconcile where they
actually point to a stable heading. They don't all compete in needing to resolve. More — which ones
are we selected and the rest was the comparison."**_

**★ THIS FILE IS THE SELECTION.** Every row is something Battlewrath settled, dated, with where it
was settled. The alternatives that were weighed against them are in §C — **named once so nobody
re-runs the comparison**, and evidenced in `audit/` where the working was done.

⚠ **Status, as everywhere in this folder: best working model at its date.** Held until an
insufficiency shows; never re-litigated on preference.

⚠ **Scope.** This governs the STORED and EXPORTED form. It defers to
`driver_programmatic_model.md` (#4) on what an authoring term MEANS, and to
`driver_stored_state.md` for what the editor's store actually holds today.

---

## A · THE SELECTED MODEL

### A1 · Records

1. **TWO RECORD KINDS, BOTH KEYED BY THE ADDRESS.** A CHARACTERISTIC record per node, and N
   BEHAVIOUR records (one per action tab). *(RI-23, RI-25)*

        CHARACTERISTIC   MapID:RID:BID:CID : Stage : Step : POS : R : Band : Next(Type,arg) : Trigger
        BEHAVIOUR        MapID:RID:BID:CID : Sense : action : arg

   ⚠⚠ **`Trigger` MOVED TO THE NODE 2026-08-19** (Battlewrath, his best working model:
   *"the trigger is on the node not the action tabs"*). It had been drawn on the BEHAVIOUR
   record by the Analyst, and **two sources already disagreed with that**: the shipped row is
   `{ sense, action, arg }` with no trigger field (`routes.lua:1057`), and RI-17's grammar is
   three parts, `<sense>:<action>:<arg>`. ⚠ A third support I cited — `child.ifUnseen` — is
   STRUCK: that field is gated on `role == "set"` and is not the Trigger control, which the
   record says is NOT BUILT with no code term chosen (`driver_adaptor_table.md:147`). ★ **The move makes the BEHAVIOUR record and the ruled grammar the
   same thing** — the trigger slot was the only field on the row that the grammar never had.
   ⚠ What it means at node level is RI-27's remaining half: may a node run again once it has
   completed? His case is a recovery beacon that must not keep re-setting the stage.
   ⚠⚠ **AND THE CONTROL IS NOT BUILT.** `driver_adaptor_table.md:147`: *"the once | every
   control — NOT BUILT; code term the bench's the day it lands (no identifier invented
   here)."* ★ Stated here because it lived only in the adaptor table, where nobody reading
   the data model would meet it — and its absence is what let an afternoon go into
   reconciling this slot against a field that was never it.
2. **OWNERSHIP IS THE ADDRESS. There is no ownership table.** A record states its whole ancestry in
   its own key, which is how the note and names tables already work. An ownership table would be
   the only structure in the model that could disagree with the tree it describes. *(RI-25)*
3. **THE NODE IS THE UNIT THAT MUST STAND ALONE; a row is never interpretable cold.** Settled by
   the walk's own gate order — a recovery beacon cannot pass a stage gate, so it is found as a
   NODE. This is what made the repetition not load-bearing. *(RI-23)*
4. **NODE FIELDS APPEAR ONCE.** Eleven fields previously repeated per row and could disagree with
   themselves; under A1.1 there is nothing left to reconcile. *(RI-23, retiring RI-18 Q2 / G3)*

### A2 · What may appear in a record

5. **IDENTIFIERS AND NUMBERS ONLY. No free text anywhere on a record**, `arg` included — it is an
   ID reference. Nothing to escape, no reserved character to defend. *(RI-18)*
6. **TWO SIDE TABLES THE DRIVER NEVER OPENS** — NAMES (`MapID` · `RID:Name` · `RID:BID:Name` ·
   `RID:BID:CID:Name`) and NOTES (`RID:BID:CID:NoteID : content`), each with exactly one free field,
   LAST after its key. *(RI-18)*
7. **NOTES ARE STORED BY `NoteID` IN THE EDITOR TOO**, not only in the export — which makes sharing
   a later re-point rather than a feature. *(RI-18 Q6)*
8. **THE DISCRIMINATOR FOR WHAT SHIPS IS WHO DEFINES THE VALUE.** Config we control (senses,
   actions, the radius menu, bands) — the driver already has it, nothing goes on the wire. Derived
   from a run (boss names) — the consumer cannot know it, so it MUST ship as a table. Free text
   falls out as the residue. *(§382)*

### A3 · Numbers

9. **BEACON STAGES ARE WHOLE NUMBERS ONLY**; child ordinals are the author's choice (`1.1 · 1.2` or
   `1 · 2 · 3`). ⚠⚠ ~~Already enforced by the mint~~ **CORRECTED 2026-08-19 (sub-agent audit, verified):
   THE MINT CANNOT PRODUCE A FRACTION; THREE OTHER DOORS ACCEPT ONE.** `NextStage`
   (`routes.lua:304`) walks whole numbers - but `AddBeacon`’s `stage` argument passes any
   number through (`:347`), `SetStage` is a bare `tonumber` (`:1483-1489`), and the
   promoter’s box is deliberately NOT numeric (`promoter.lua:535`: *"NOT SetNumeric: 4.1 is
   the whole point of the field existing"*). **The guard arrives with the pickers (A10.3e),
   and until then the rule is a ruling with no enforcement.** ★ Still load-bearing: `Routes.Outcome`'s `+ 1` and
   `Routes.Gaps`' integer loop are each correct only while nothing sits between `n` and `n+1`.
   *(RI-23; his best working model, 2026-08-19)*
10. **STAGE 0 / STEP 0 MEANS ALWAYS ELIGIBLE** — `nil` in the store, `0` on the record. A value,
    never an empty slot, because missing / absent / truncated all look alike. *(§385c)*
11. **`Stage:Step` ARE COMPOSED AT EXPORT** from the live tree. They are properties, so storing
    them in a key would re-key a note the first time anyone reordered anything. *(proposition §3)*
12. **`Next` IS ONE FIELD, `(Type, arg)`** — Step · Stage · Set(N), the arg present only for Set.
    *(DRIVER_BASIS:181, RI-18 Q3, restated RI-25)*

### A3b · The band

12a. **THE BAND IS UPWARD ONLY — one value, not a pair.** Default **2.5 yards**, offered as an
    ADVANCED option at the foot of the list, and **the STORE holds the number, not the menu
    index** — the choice is a lookup. ★ His reason, corroborated rather than taken: *"our data
    points are captured from the floor level"* — `ROUTER` §280 has a unit's z as its BASE POINT,
    so a sample IS the floor and downward tolerance measures nothing; and 2.5 up covers the
    measured jump apex of ~1.64. ⚠ `walk.py` already takes `band_up` and `band_down` separately,
    so this is `band_down = 0`, not a signature change — what moves is W1.7's fixtures and W3.2's
    sweep, **not the w5 goldens**, which are produced with bands OPEN and say so in their own
    header. *(RI-22, 2026-08-20)*

### A4 · The export

13. **THE EXPORT IS A PROJECTION OF THE STORE, NOT A COPY.** Deliberately not 1:1. *(RI-18 Q1)*
14. **EXPORT IS EDITOR-SIDE, ALWAYS** — composing `Stage:Step` needs the live tree — and it is
    written in ONE PASS over a finished tree; nothing is ever appended to a written file.
    *(proposition G11, §381b)*
15. **IMPORT RECONCILES AND TELLS**; row order is part of the format and is ASSERTED AT INGEST,
    never depended on by the runtime pass. *(RI-18 Q2 (b), Q5)*
16. **ON IMPORT ONLY THE RID RE-MINTS.** `BID:CID` carry unchanged; an export and its origin become
    two routes, never two versions. *(RI-4)*
17. ~~**NO VERSION TOKEN NOW.**~~ **A VERSION PREFIX FROM THE FIRST STRING (2026-08-20).**
    ⚠⚠ OVERTURNED by the transport choice, not by a new argument. The deferral held while a
    reader could LOOK at what they got; **an encoded blob is the case where nobody can**, so
    a decode failure and "this is from a newer version" become the same event. ★ WeakAuras
    carries `!WA:2!` on this fork for exactly that, and its own comment says *"N is encode
    version"*. It is a few bytes and it goes in front of the payload. ~~There is no V1 and no
    installed base, so there is no stale reader to protect~~ — true, and it stops being the
    deciding fact once the string is opaque. *(RI-20 P1 · RI-26)*


17a. **THE TRANSPORT: SERIALISE → COMPRESS → ENCODE, BEHIND A VERSION PREFIX.** AceSerializer
    (shipped, `Ace3/wotlk-r960`) → LibDeflate compression → `LibDeflate:EncodeForPrint`. ★ One
    vendored library, proven on this fork — WeakAuras uses it here. *(RI-26, 2026-08-20)*
17b. **THE LOAD IS TWO STAGES.** Decode and PRESENT — map, route name, bosses — then *"save this
    as a route?"*; on accept it becomes a saved route, written to SavedVariables on reload or
    logout. ★ The preview needs only the two side tables of A2.6, so nothing extra is carried to
    make it work. *(RI-26)*
17c. **THE SURFACE IS A MULTI-LINE EDIT BOX, NEVER CHAT.** `ROUTER:123` — the chat edit box is
    capped at 255 letters and a route is ~2 KB. *(RI-26)*
17d. **NOTHING SCRAPED ABOUT THE CHARACTER TRAVELS.** `author` was minted as `UnitName("player")`
    — scraped, and shipped. It is replaced by **who / when / author notes the user supplies**.
    ⚠ Not "speculative or needed" — **wrongly sourced**. Same law as RI-4's *the origin on someone
    else's data does not travel*. *(RI-24, 2026-08-20)*

### A5 · The consumer

18. **THE DRIVER IS A PURE RULE PLUS A STATEFUL SENSOR.** The rule is point + segment + band and
    holds nothing. The sensor is the armed object: it holds the resolved parameter inventory, the
    in-set, the two gate sets, and — at V2 — the per-tab completion ledger. *(RI-25, A11.3)*
19. **INGEST BUILDS THE INDEX; THE 1 Hz PASS WALKS BUCKETS, NEVER RECORDS.** So read count is an
    ingest cost paid once and must not shape the format. *(A11.1a)*
20. **CONFIG INDEXES RESOLVE ONCE AT INGEST**, never per sample. *(A11.4b)*
21. **ONE GEOMETRY EVALUATION PER NODE PER SAMPLE, SHARED BY ITS ROWS.** Correctness, not economy:
    all-tabs-complete needs every tab to agree about one in/out transition. *(A11.2g)*
22. **THE SENSOR HOLDS A GATED SET AND AN ALWAYS-OPEN SET** (stage 0, and ordinalless children
    within their stage). *(A11.3d)*

---

## B · STILL OPEN — with who moves next

    P2a   the REJECTION half of the coordinate bound. Its INPUT half dissolved when every
          numeric door became a selection; what remains is IMPORT, which has no picker.
          ⚠ NARROWED 2026-08-20: the transport now decodes a serialised structure rather than
          parsing a hand-editable line, so the "hand-edited file" case is a DECODE failure.
          What survives is a value that decodes cleanly and is still out of range. Battlewrath

    ✓ CLEARED 2026-08-20, all in the RI-26 landing - listed rather than deleted so a reader who
      remembers them sees where they went:
        G5    -> §A4 row 17a THE TRANSPORT, and 17b/17c the load and the surface.
        RI-22 -> §A3b row 12a THE BAND IS UPWARD ONLY. One value, 2.5, stored as the number.
        RI-24 -> §A4 row 17d NOTHING SCRAPED TRAVELS. `author` was wrongly sourced.
        G7    -> HALF ANSWERED by 12a: Band is no longer compound, so only POS is, and its
                 internal separator is a question for the SERIALISER rather than for a line
                 format. ⚠ It stops being a design question and becomes an implementation one.

## C · COMPARED AND NOT SELECTED — recorded once so it is not re-run

    a version token on every line          RI-20 P1 · WeakAuras `!WA:2!`, GPX. De-prioritised, A17.
    a length prefix / TLV / fixed-width    RI-21 D4, D10 · the alternatives to a version. Our `arg`
      generic payload                      is variable-width and last, which is the case they miss.
    delta encoding                         RI-21 D2 · costs random access; always-listen recovery
    modal state                            RI-21 D12 · same currency, priced out by the same rule
    a checksum / magic number              RI-21 D1 · real failure mode (a pasted route through a
                                           newline-translating client), NOT selected. → SEED S1
    a header carrying the terms            RI-21 D3 · nothing needs one yet
    delta/packed coordinates               RI-20 P2 · GatherMate packs NORMALISED fractions; ours
                                           are world coordinates. The architecture transfers, the
                                           packing does not.
    an ownership table                     RI-25 · a second mechanism for what the address carries
    stage as an index into a table         RI-23 · stage is ordered, compared, incremented and
                                           typed into an address. Only the INPUT is a selection.
    a builder that auto-rebalances         §385e · WITHDRAWN: nothing auto-updates
    fractional beacon stages               RI-23 · they would break `Outcome` and `Gaps`, both
                                           shipped and correct under whole numbers
    ~99,900 addresses as an affordance     §385h · a correct number that misleads; the claim is
      claim                                ~~99 slots between any two majors~~ ⚠ SUPERSEDED
                                           2026-08-20: child ordinals are `x.x` - NINE slots.
                                           Narrowed on SCOPE, not on arithmetic: *"we are not
                                           making a real time combat guide."*

_Evidence for all of the above: `history/peer_data_stores.md` · `history/prior_art_formats.md` ·
`history/prior_art_execution.md` · `history/data_model_findings.md`._

## D · SEEDED — future work, not now

    S1  TRANSFER CORRUPTION has no detector. A route string will be pasted through chat, Discord,
        a forum and an editor; a newline-translating round trip parses into a WRONG ROUTE rather
        than failing. PNG's signature catches exactly this. ⚠ Whether it earns a byte is a
        decision nobody has made. (RI-21 D1)
    S2  THE VERSION RETROFIT, if it is ever needed: an absent version IS a version (Amazon States
        Language). Costs nothing to adopt later, which is why A17 is safe. (RI-21 D13)
    S3  WHO RESOLVES NAMES for a human-facing readout that is not editor-side. (proposition G8)
    S4  NO UPDATE PATH by construction: an import is a sibling, never a successor, and the two are
        indistinguishable except by RID — which makes `promoter.id` load-bearing beyond its
        original job. (proposition G2)
    S5  THE ORDINAL PICKER HAS NO MINT AND NO GAP FUNCTION. `NextStage` and `Gaps` exist for
        stages; nothing equivalent exists for child ordinals. (RI-23)
    S6  `fireOn` — a field RI-5 retired, with a live setter and no caller. Remove whole, the way
        A2.6 removed `goTo` and `onRamp`. (RI-24 D-1)
    S12 THE SESSION SHARE, deferred on purpose (Battlewrath, 2026-08-20). People meet for a
        session and there is no external source in that moment, so a hidden-channel batch
        share between users is eventually wanted. * The transport already accommodates it:
        LibDeflate ships EncodeForPrint AND EncodeForWoWAddonChannel, so it is an encoder
        swap plus chunking, not a format change. ! The per-message cap on this client is NOT
        in ROUTER - measure it the day it is built.
    S10 THE NAME AND NOTE TABLES INHERIT THE RE-MINT (proposition G9). Only the RID re-mints
        on import (A4.16), so every key in the two side tables re-mints with it. A8.4's
        migration hook must walk them too - a criterion the day the tables land.
    S11 THE NOTE RE-KEY IS RULED AND UNBUILT (proposition G10). A2.7 stores notes by
        `NoteID`; the shipped store keys the TEXT by address (`routes.lua:1576-1597`,
        `store.lua:471`). A4.2 records the migration as owed through A8.4's hook. ⚠ Named
        here because `driver_stored_state.md` §4 lists only two debts and this is a third -
        a ruling the code has not reached, which is a different thing from a dead field.
    S8  ★★ THE ROW GRAMMAR CANNOT BE AUTHORED IN-GAME. `Routes.SetRow` / `RowsOf` have no
        PRODUCTION caller — ⚠ CORRECTED 2026-08-19: I first wrote "ZERO callers outside
        routes.lua" and `smoke_dungeonrunroutes.lua` calls both. My grep covered the addon and
        not the smokes. They are TEST-ONLY: graded, not wired. `object.lua` still calls
        `SetChildSense`, `SetChildRole` and `SetChildAction` - the shape the docs mark
        superseded. ⚠ So the row model the export and the driver are SPECIFIED AGAINST is
        unreachable through the shipped pane. `adaptor.lua:67-70` says as much about itself
        ("the old pane is LIVE until then"). A10.3 is the replacement; this names the gap.
    S9  ⚠⚠ THE DESK’S GOLDENS WERE PRODUCED BY A NARROWER RULE THAN W1.10 GRADES. The
        teleport guard `v_max` is applied in `transits` (`walk.py:571`) and is ABSENT from
        all three `broken` recomputations (`:1047 · :1159 · :1276`) - the paths that produce
        the w5 goldens. ★ W7.1 demands the Lua port be BYTE-EQUAL to the desk, so the port
        must reproduce the narrower rule while W7.2 grades the wider one. ⚠ REPORTED, NOT
        RESOLVED: which rule is right is a decision, and changing either MOVES A GOLDEN.
    S7  `AddBeacon` FORCES A STAGE, so the stageless recovery beacon has no path in — now a
        PRECONDITION for A10.3e's stage half rather than an owed nicety. (§366, A10.3e)

## E · MODEL THAT STILL NEEDS DETAILING

    E1  THE SENSOR'S CONTRACT. A11.3c names the REQUIREMENT (resettable, state readable) and not
        the shape: what arm / disarm / reset take and return, and what "read the state" exposes.
        ⚠ Needed before the port, because W7.1 is graded through it.
    E2  THE COMPLETION LEDGER (V2). A2.7 specifies the rule completely; the ledger's shape - per
        node, per tab, its interaction with Trigger, and what a wipe does to it - is undrawn.
    E3  THE SIDE TABLES' EXACT KEY FORMS, and where they sit relative to the records.
    E4  WHAT PROVENANCE SURVIVES AN IMPORT - blocked on RI-24, and testable at the same time as
        A8.5's export-travel half.
