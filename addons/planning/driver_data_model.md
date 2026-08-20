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
4a. **THE TWO KINDS ARE A TABLE AND AN INSTRUCTION SET — and the instruction set is defined by its
   ORDER and its RESOLUTION, not by which fields it holds.** Battlewrath, 2026-08-20:
   *"Tables and a instruction set."* · *"The model moved on from POS:R:BAND:NEXT:TRIG being in the
   instruction set. Those live in the tables."* · **"It's the order (By gate) and instruction set
   against functions the driver will know how to resolve."**

        TABLE             the CHARACTERISTIC record — POS, R, Band, Next, Trigger, Stage, Step.
                          Absolute values. Resolved at AUTHORING time; the driver is handed them.
        INSTRUCTION SET   the BEHAVIOUR records — `Sense:action:arg`. ORDERED BY GATE, and every
                          term is a REFERENCE the driver resolves against functions it already has.

   ★★★ **AND THE GATE IS A BOUNCE, NOT A SORT KEY** *(Battlewrath, 2026-08-20)*:

   > *"`MapID:RID:Stage:Step:` will bounce everything that doesn't match or it can't read through
   > on. (0) being a continue gate. Or where mapID, RID, stage and step match."*

   ⟶ A record is admitted on **`0` (CONTINUE) or an exact match**, and bounced otherwise — the
   four-part prefix is evaluated FIRST, before anything geometric. ★ This is the same `0` as
   *"Stage 0 / Step 0 is permission to read it"*: `nil` in the STORE, `0` on the RECORD, and
   **continue** at the gate.
   ⚠⚠ **IT IS NOT `Rule.Gate`.** A11.2a defines the RULE's gate as *"same mapID, tested FIRST"* and
   nothing more, and that is correct: the rule sees a SAMPLE and a NODE, and a sample carries a
   mapID and no `RID`, `Stage` or `Step`. ★ **The prefix bounce tests a record against the DRIVER'S
   STATE**, which is the instruction set's business, not the rule's. Two gates, different operands,
   both named "gate" — written down here so the next reader does not merge them.
   ★ **In a STAGELESS V1 (A11.5a) the stage half is inert but present in shape:** every node's stage
   is `nil`, `nil` reads as `0`, `0` continues — so the prefix reduces to `MapID:RID` in practice
   without the rule changing form when stages arrive.
   ★★★ **AND THE BOUNCE IS RESOLVED AT INGEST, BY BUCKETING — NOT PER POLL.** *"There are 2 layers.
   The sensor doesn't carry both. The sensor checks against the current bucket / pre-load items
   ⚠ **"pre-load" IS RETIRED AS A TERM (2026-08-20)** — the phases are BUCKET and STAGE,
   rows 23–27. His words are kept verbatim because they are the DIRECTION; only the label moved."*
   (Battlewrath, 2026-08-20), which is **A11.3d already**: the sensor holds a **GATED set** (nodes
   at the current stage/step) and an **ALWAYS-OPEN set** (stage 0, ordinalless children) — the
   second *"built once at ingest and never re-tested against the gate"*. A11.1a builds the index
   as `mapID → stage → ordinal` buckets and *"the 1 Hz pass walks the bucket, never the lines"*.
   ⚠⚠ **THAT CONSTRUCTION IS IN #11 AND NOTHING OF IT IS IN THIS FILE — see RI-36.** This file
   declares itself the entry point for the stored and exported form and says nothing about how any
   of it is LOADED. ★ His words: *"clearly the model isn't specific enough on construction."*
   The bench read #3, found no construction, and invented a fork that #11 had already closed.

   ★ **The ORDER comes from the gates** (`Stage:Step`), whose values sit on the table — the gate
   is stored once as a characteristic and *read as sequence* by the instruction set. ⚠ This is not
   a second copy: nothing is ordered by position in a file, which is the property A1.1's
   *"reconstruction by matching the node prefix, never by order"* already protects.
   ★★ **And "resolve against functions the driver will know" is A2.8's discriminator arriving from
   the other side:** senses and actions are config WE control, so the driver already holds them and
   nothing about them goes on the wire — the record carries the NAME, the driver owns the function.
   ⚠⚠ **Filed by the Addons bench 2026-08-20 (§429) because §428 nearly lost it.** "Gates first"
   was written INSIDE the flat LINE, which §428 struck as superseded with *"it directs nothing"* —
   true of the field inventory, **false of the ordering**. ★ A live property was riding inside a
   dead shape, and striking the shape took it down. *A grep finds moved words; it cannot find moved
   load* — here in its mirror image: **the words moved and the load did not.**
   ⚠ `flight list` is the prior/code vocabulary for `instruction set`
   (`driver_reconciliation.md:45`), and it is NOT DYNAMIC — fixed once armed, in both the Editor
   and the driver *(Battlewrath, 2026-08-20)*.

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

12a. **THE BAND IS UPWARD ONLY — one value, not a pair.** **2.5 yards is both the DEFAULT
    and the MINIMUM OFFERED** — the list runs upward from it (Battlewrath, RI-35: *"2.5 above
    the lowest offered"*, i.e. 2.5-and-above IS the offering; ⚠ the bench first read this as
    "2.5 sits above some lower offer" and was corrected). ★ A floor below 2.5 would have been
    the one value in the design pointing DOWNWARD, against this row’s own reason. Offered as an
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

18. **THE DRIVER IS A PURE RULE PLUS A STATEFUL SENSOR.** The rule is **point + band + gate**
    and holds nothing. ⚠⚠ **AMENDED 2026-08-20 (RI-33, his own drain): was "point + segment +
    band".** Segment interpolation, the interpolated z and `v_max` are DESK-side — the desk
    reconstructs a fixed-cadence recording and must interpolate; the driver controls when it
    looks. The sensor is the armed object: it holds the resolved parameter inventory, the
    in-set, the two gate sets, and — at V2 — the per-tab completion ledger. *(RI-25, A11.3)*
19. **INGEST BUILDS THE INDEX; THE 1 Hz PASS WALKS BUCKETS, NEVER RECORDS.** So read count is an
    ingest cost paid once and must not shape the format. *(A11.1a)*
20. **CONFIG INDEXES RESOLVE ONCE AT INGEST**, never per sample. *(A11.4b)*
21. **ONE GEOMETRY EVALUATION PER NODE PER SAMPLE, SHARED BY ITS ROWS.** Correctness, not economy:
    all-tabs-complete needs every tab to agree about one in/out transition. *(A11.2g)*
22. **THE SENSOR HOLDS A GATED SET AND AN ALWAYS-OPEN SET** (stage 0, and ordinalless children
    within their stage). *(A11.3d)*

---

### A5b · Construction — how a stored route becomes a thing the driver can run

_Added 2026-08-20 (RI-36). ★ The gap this closes, in the item's own words: **a reader arriving at
the governing entry point learned what a record IS and nothing about how it becomes a thing the
driver can run.** Battlewrath's direction: *"stage the material that fit within the current gate…
by the time it's sampling it should have a target in mind."*_

23. **CONSTRUCTION IS TWO PHASES, NAMED BY WHAT THEY DO.** The term "pre-load" is retired.

        BUCKET   once per run.   Read the offered store WHOLE — the client hands us all of
                                 SavedVariables and we do not choose the section — keep this
                                 MAP for relevance, pick the RID, and lay the route out as
                                 `bucket[stage][step]`.
        STAGE    per advance.    Hand the current stage's bucket, WITH stage 0, to the sensor.

    *(RI-36. The map filter is shipped precedent: `Routes.List(mapID)`, `routes.lua:335-341`,
    which the editor already uses to offer an authored route against a map.)*

24. **★★★ BUCKET MAY FAIL, AND SHOULD FAIL LOUDLY. STAGE MAY NOT FAIL.** ⚠ A stage advance
    happens MID-RUN, MID-COMBAT, and is raised by the sensor's own output — there is no good
    answer available at that moment, so validation cannot live there. **If STAGE can fail,
    BUCKET did not do its job.** *(RI-36; the field's own answer — five executor systems all
    fail at load and name what was missing.)*

25. **BUCKET RESOLVES THE ACTION, NOT ONLY THE TARGET.** Every `action` id resolves to the
    function the runtime holds and every `arg` to its value, so STAGE hands the sampler
    something CALLABLE rather than something to look up. ★ The rule it satisfies:
    **nothing authored is ever interpreted on the hot path.**

26. **A STAGE ADVANCE SWAPS BUCKETS; IT DOES NOT REBUILD.** All stage buckets are formed at
    BUCKET time, so the swap is `O(1)` in buckets and re-evaluates nothing. ⚠ **And it happens
    AFTER a poll returns, never inside one** — the sensor's result changes the sensor's input,
    so the armed list must not be mutated mid-poll.

27. **THE STORE'S `nil` BECOMES `0` AT BUCKET, ONCE.** Row 10 rules the two forms; BUCKET is
    where the conversion is performed and the only place it may be. ⚠ Today the addon pays it
    at seven scattered read sites and one converts back. ★ **The store keeps `nil` because
    absence must stay LOUD** — `nil + 1` throws, `0 + 1` silently returns 1, which is A2.10a's
    defect exactly. *(§395, `routes.lua:418-429`, which measured eight consumers against nil.)*

    ⚠⚠ **AND THE CONVERSION IS PER FIELD, NOT ONE SWEEP.** `nil` means *"no constraint"* in
    both cases and the two land on OPPOSITE ends of the number line:

        stage / step   nil → 0      "always eligible" - a gate you must MATCH relaxes to 0
        band           nil → 2.5    "the author did not pick" - RI-2's nil, and 2.5 is the
                                    picker's FLOOR and DEFAULT at once (RI-35)

    ★ A blanket `nil → 0` would give every unpicked band a tolerance of ZERO — `dz` must be
    exactly 0 — which is the most restrictive value produced from an absence that means
    "unset". **BUCKET converts by field, and the value is the field's own default.**
    ⚠⚠ *(RI-37, retired: the Analyst first wrote `nil → ∞` here, reading `Rule.OPEN` — the pure
    rule's fallback for a nil it may be handed — as though it were a data state an author could
    author. **There is no open band; the menu is closed and floors at 2.5.**)*

    ⚠⚠⚠ **AND THIS ROW CURRENTLY DISAGREES WITH THE CODE. `rule.lua:93` DOES `dz <= (bandUp or
    Rule.OPEN)`** — nil means ∞ there, not 2.5. ★ The Analyst wrote this row's correction and
    left the code saying the opposite; **the disagreement is FILED as `A11.2h`, not resolved by
    editing either side.** *"Don't mutate code from doc disagreement"* (Battlewrath, 2026-08-20).
    ⟶ Until A11.2h is answered, **row 27 is the intent and `rule.lua` is the fact.**

#### ★★ PEER SHAPE, CITED BY FUNCTION SO IT CAN BE INSPECTED

⚠⚠ **CITED FOR SHAPE, NOT FOR IMPLEMENTATION.** *Precedence is the proof we can, not the
implementation the addon needs.* Read these to see the pattern working in a shipped addon on this
client; do not port them.

    WeakAuras/GenericTrigger.lua:1387   LoadEvent             fills `loaded_events[event]
                                                              [subevent][id]` at LOAD
    WeakAuras/GenericTrigger.lua:885    Private.ScanEvents    the hot path INDEXES that table
                                                              and early-outs; no search
    WeakAuras/GenericTrigger.lua:1248   GenericTrigger        moves ids OUT incrementally;
                                        .UnloadDisplays       only UnloadAll wipes
    WeakAuras/WeakAuras.lua:1529        scanForLoadsImpl      re-evaluates each aura's COMPILED
                                                              `loadFuncs[id]` on a state change
    WeakAuras/WeakAuras.lua:1692        (loadFrame events)    the ~14 state events that drive it
    WeakAuras/AuraEnvironment.lua:640   CreateFunctionCache   authored text compiled ONCE to a
                                        `cache.Load` (:644)   function and cached
    COA_DungeonRun/routes.lua:335       Routes.List           OUR OWN shipped map filter

⚠ Every line above was checked to resolve to the named declaration on 2026-08-20. **Two were
wrong on first writing** — cited at the line where the table is FILLED rather than where the
function is DECLARED — which is the citation-rot shape this project has met before.

★ **What we take is the load-condition MACHINERY driven from a different input** (Battlewrath):
*"Their dynamic. We just take that for the stage rather than player state."* ⟶ WA needs ~14
registered state events and must re-check every aura when one fires; **our load condition has one
input and one source of change**, so an advance moves two buckets and re-evaluates nothing.

⚠ **AND ONE THING THAT DOES NOT TRANSFER:** WA is EVENT-driven and we are POLL-driven. Their
biggest saving is the early-out — *no aura cares about this event, return* — and we have no
analogue, because we always have a sample. **Our saving comes from the bucket being SMALL.**

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
        the w5 goldens. ✅ **DISSOLVED 2026-08-20 BY RI-33, and this one dissolved for free.**
        It read *"W7.1 demands the Lua port be BYTE-EQUAL to the desk, so the port must
        reproduce the narrower rule while W7.2 grades the wider one — REPORTED, NOT RESOLVED"*.
        ★ With byte-equality moved to the desk's own calibration, **the port never has to
        reproduce the desk's narrower rule at all.** The `v_max` inconsistency stays a DESK
        question about the desk's own goldens and stops being a driver blocker. ⚠ Still open
        ON THE DESK, and still moves a golden if resolved either way.
    S7  `AddBeacon` FORCES A STAGE, so the stageless recovery beacon has no path in — now a
        PRECONDITION for A10.3e's stage half rather than an owed nicety. (§366, A10.3e)

## E · MODEL THAT STILL NEEDS DETAILING

    E1  THE SENSOR'S CONTRACT. A11.3c names the REQUIREMENT (resettable, state readable) and not
        the shape: what arm / disarm / reset take and return, and what "read the state" exposes.
        ⚠ Needed before the port — 2026-08-20 the reason changed and the requirement did not:
        the sensor is where OUTCOME grading is read from, so its contract still gates P4.
    E2  THE COMPLETION LEDGER (V2). A2.7 specifies the rule completely; the ledger's shape - per
        node, per tab, its interaction with Trigger, and what a wipe does to it - is undrawn.
    E3  THE SIDE TABLES' EXACT KEY FORMS, and where they sit relative to the records.
    E4  WHAT PROVENANCE SURVIVES AN IMPORT - blocked on RI-24, and testable at the same time as
        A8.5's export-travel half.
