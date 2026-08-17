# EXPRESSIONS — what this project has been trying to let an author SAY and a reader RECEIVE

_Independent audit, files only, 2026-08-17. Read in full: `dungeonrun_model.md` (M), `mvp_scope.md`
(S), `driver_design_advisory.md` (D), `driver_use_case_target.md` (T), `driver_scoping.md` (SC),
`COA_DungeonRun/routes.lua` (R), `editor.lua` (E), plus `object.lua` (O) and `promoter.lua` (P) —
because `editor.lua` is the CURATION pane (runs, filters, time window; `E:1-46`) and the beacon /
child authoring controls live in `object.lua` and `promoter.lua`. `operations/ROUTER.md` (RT)
rows 84-88, 96-99, 107-108. Also consulted `audit/audit_A_prior_work.md §A5` (a rename table)
and `map.lua` (MP) for the palette and hover readout._

_Reported as data. Citations are `FILE:line` or `FILE §heading-line`. Status ∈ {in code ·
designed only · ruled out}. "in code (no door)" = a Routes setter exists with no UI caller._

---

## E1. AUTHOR EXPRESSIONS

| # | the author says… | attaches to | model word | code word | advisory / target / scoping word | cited | status |
|---|---|---|---|---|---|---|---|
| A1 | "this route is called X" | route | label — *what does my label say* (M:1118, 1144-1147) | `name`; `Routes.Create/Rename` (R:94-119); name box + Rename popup (P:100-113, 273-289) | `meta.origin` (D §12:304) | R:86-93 id≠name | in code |
| A2 | "this route belongs to dungeon M" | route | — (routes offered only for the loaded map, R:133-160 comment) | `mapID`; `Routes.List(mapID)` (R:146-160); create disabled with no map (P:187-189) | — | R:79-82 valid for a mapID, not a difficulty | in code |
| A3 | "delete this route and everything on it" | route | — | `Routes.Delete` (R:121); popup names the route, `showAlert` (P:291-311) | — | — | in code |
| A4 | "hand this route to another player" (export / import) | route | *exportable; replaced wholesale on import* (M:571); sanitise at import (M:337-352) | none built; comments only (R:16-17, 529-532, 1101) | route package `meta/flat/source`, string, `schema_version` (D §12:285-343); copy-paste string or in-dungeon channel (T §5:93-97) | SC S11: **off the books, build so we can** | designed only |
| A5 | "say this in chat when this is reached" (announce) | route / beacon | announce — *the author supplies a MESSAGE, the command is ours*; runner ticks consent on the driver (M:456-483); nearest edge of *inform, don't act* (M:262-266) | none (`grep announce` → comments only) | — (T §6:113 *never push*) | M:435-437 sink = `SendChatMessage(msg,"SAY")` | designed only |
| A6 | "how far ahead the driver may listen" (K) | route | — (far-stage policy OPEN, M:995-999) | — | forward listen K=3, *author knob* (D §2:44-46); a config, not the chain default (D §13:392-397) | SC S6 → ratchet + maxSeen tracked | designed only |
| A7 | "this route is format version N" | route | — | — | `schema_version` from day one (D §12:338-339) | — | designed only |
| A8 | "put a beacon at this captured spot" (mint from a node) | beacon | *capture is the only spawn* (M:82-102); promotion = reduction (M:689-709) | `Routes.AddBeacon(id,node,stage)`, `Inherit` PLACE whitelist (R:48-60, 219-230); **Create beacon** (P:191, 335-354) | seed once, carry forever (D §12:311-317); *every position is a copied read* (T §3:72) | R:223 refuse if no map position | in code |
| A9 | "this beacon is stage N" | beacon | stage — *structural but ordinal* (M:727-740); ghost = next free round number (M:723-725) | `stage`, `SetStage` (R:1023-1029), `NextStage` walks gaps (R:185-193); stage box (O:486-526); ghost on mint (P:155-166, 342-346) | stage order = row order (D §13:352); *stage as a ratchet* (T §3:65) | — | in code |
| A10 | "insert 4.1 between 4 and 5" (fractional stage) | beacon | *the fraction is the intended expression* (M:737-740) | `tonumber`; stage box NOT `SetNumeric` (O:491, 567-568); never generated, only typed (R:182-184) | — (D §3:73 uses 4.1/4.2 for CHILDREN — see C10) | — | in code |
| A11 | "two beacons share a stage" (allowed, told) | beacon | *no validation — tell and trust*; match count is telling the author the ordinal stopped being ordinal (M:742-746) | `StageMatches` (R:1033-1042); `match N` / `free` beside the box (O:254-257) | SC S4: **tell and trust** | R:200-202 consequence is theirs | in code |
| A12 | "this beacon is called X" | beacon | label (M:1118) | `SetName` (R:311-316); name box in-field (O:435-441, 364-369) | — | — | in code |
| A13 | "move this beacon here, keeping where it was born" | beacon / child / note | *gate on ORIGIN not POSITION* (M:96-102); `atX/atY` nil = never moved (M:1213-1215) | `Place/Unplace/PositionOf/WorldOf` NEW else ORIGINAL (R:233-305); **move** chip (O:449-462); drag, click drops (MP:1755-1819) | re-seat only, no free point (D §12:314-317); SC S1 **DECISION: free placement** | — | in code (S1 rules the code's way; D §12 wording ruled out) |
| A14 | "when satisfied, advance (+1)" | beacon | ratchet `index = max(index, outcome)` (M:716) | `Outcome` = `stage+1`, stored nil (R:973-1008, 1067-1070); **advance (+1)** (O:546) | `A complete` (D §13:370) | — | in code |
| A15 | "when satisfied, go to stage N" (checkpoint) | beacon | *a checkpoint is a cheap beacon… the outcome of satisfaction* (M:714-717) | `SetOutcome`, `outcome` (R:1000-1008); **go to stage** + box (O:547, 562-574) | — | R:984 *a beacon whose outcome you typed* | in code |
| A16 | "come here" — the beacon points to itself | beacon | *a beacon points to SELF* (M:928-946); on-ramp (M:643) | `OnRampOf` falls back to the beacon (R:859-868) | **RULED: only lures, a beacon points to self** (D §13:373-379); childless beacon *on-enter lure is its own pointer* (D §3:69-70) | S:27 on-ramp | in code (as fallback) |
| A17 | "done when found" — a childless beacon completes itself | beacon | *the anchor is its own satisfier when childless* (M:647-649) | `AcceptanceOf` returns `b` when no children (R:893-902) | self-completing (D §3:69); SC §R S2 addendum *self-contained* | — | in code |
| A18 | "how close counts as reaching this (childless) beacon" | beacon | — shape/reach are CHILD words (M:609); *our rejection is the shape* (M:903-919) | **none** — `SetChildReach` is child-only (R:688-694); no beacon radius field | childless face = *supertracker y/n and the reach* (S:66-68); `position + R ±H` (D §3:69); *radius + band per place* (T §3:64) | — | designed only |
| A19 | "this beacon is a theatre; the acting happens at its children, not at its dot" | beacon | anchor demoted to a LABEL POSITION, *nothing downstream may consume it* (M:585-596); theatre (M:578-583) | on-ramp / acceptance move to children (R:862-902); anchor is *a name for a place* (R:365-367) | THEATER scene = arm zone (D §3:71-76) — **SC §R S2 DECISION (a): label + scene manager, nothing listens at the parent's position** | — | in code (model reading); arm-zone reading ruled out |
| A20 | "quieten this beacon's children so I can read the map" (per-child opacity from the beacon) | beacon (editor view) | per-child opacity, control lives ON the beacon; click restores 100% (M:774-787); tab 1 becomes the child roster (M:888-899) | none | SC §R S2 *opacity for the editing view; renaming each child from one surface* | — | designed only |
| A21 | "give this to the player" (a note the reader gets on arrival) | beacon / child | note — one of the three answers (M:643); the readout box's second life (M:268-290); flight list *Set note Y* (M:1017) | **none** — per-child note removed (R:569-574, 802-812); `ACTIONS = {"supertrack"}` (R:574) | `A note "…"` per child (D §5:132-134, §13:367-368); *note is a CHOICE option, ≤ ~200 chars* (T §4:89); S:40 OUT of v1; SC S8 (v2) agreed | — | designed only |
| A22 | "delete this beacon" | beacon | — | `DeleteBeacon` by id (R:344-353); popup (O:372-401) | — | R:333-343 by ID not stage | in code |
| A23 | "add a child at the beacon's own spot" | child | *children ARE the everyman surface* (M:598-620) | `AddChildHere` (R:454-462); **child here** (O:594-609) | — | — | in code |
| A24 | "add a child at a captured node I pick" | child | *sample-sourced, and absolute* (M:622-633) | `AddChildFromNode` (R:440-444); **child at node** arms a pick (O:617-641) | — | — | in code |
| A25 | "this child is called X" | child | label | `SetName` (R:311); name box | — | — | in code |
| A26 | "when this child is reached, the stage completes" | child | condition: role (M:610); ratchet (M:645); *any child with the flag satisfies* | role `complete` (R:560-567); `SetChildRole` (R:605-618); **stage complete** (O:660) | completor, *typed*, any-of allowed (D §3:82-84); `A complete` (D §13:370-371) | R:581-599 not exclusive | in code |
| A27 | "when reached, set the stage to N" | child | `set` — *writes the ratchet absolutely; the only authored backwards move* (M:965, 984-993) | role `set` + `setStage` (R:565-566, 620-629); **set stage** + box (O:661, 682-690); exclusive (R:596-612) | hard resync / authoritative SET (D §2:47-49); recovery beacon *Boss killed → set:stage(N)* (SC §R S6) | — | in code (position-triggered); boss-triggered → A43 |
| A28 | "this child marks the start of the stage" | child | — | role `start` *annotates arrival* (R:562); **start of stage** (O:662) | — | — | in code (no consumer) |
| A29 | "this child marks progress within the stage" | child | — | role `update` (R:563); **updater** (O:663) | — | — | in code (no consumer) |
| A30 | "this child touches nothing" (role nothing) | child | — | `nil`; **nothing** *is a real choice* (O:656-659) | satellite *requires nothing* (D §4:115) | — | in code |
| A31 | "only fire if unseen" (repeat guard) | child | `ifUnseen` is a REPEAT guard (M:1000-1002) | `SetChildIfUnseen` default TRUE (R:631-651); **only if unseen** chip — shown only for `set` (O:310-320, 733-746) | `mode: once` — latches, spent (D §4:99-100) | — | in code (surface only for `set`) |
| A32 | "keep firing while inside" | child | — | — | `mode: while`, hysteresis (D §4:101-104); SC S5 *no prior term — new material* | — | designed only |
| A33 | "detect by radius / by trip wire" | child | detect: shape (M:609) | `SHAPES = {radius, wire}` (R:568, 653-654, 678-683); **trip wire** (O:698-699) | trigger `{xyz, R, ±H}` only (D §5:133) | — | in code |
| A34 | "how far out counts, and how far up / down" (radius + asymmetric band) | child | reach · reach.up · reach.down (M:609); *the band is a second refusal* (M:918-919) | `SetChildReach(radius, up, down)` → `radius/bandUp/bandDown` (R:685-694); three boxes (O:711-731) | `R up down`, ±H; band `open` (arm zone) vs `tight` (satisfaction) defaults (D §3:88-90, §13:351); *±2.5 tolerance* (T §3:73) | RT:102 z is the ground point | in code |
| A35 | "this child is the way in — the arrow points here when the stage begins" | child | on-ramp — *come find me* (M:643); *exactly one node carries the on-ramp* (M:950-957) | `SetChildOnRamp` exclusive (R:844-857); **the way in** chip (O:751-762) | lure; **R-e first child IS the lure, defaulted**; `lure:true, trigger:on_enter` (D §1:34-35, §5:131-132) | — | in code (declared, not defaulted) |
| A36 | "when this child fires, point the arrow at that child" | child | *"go to Y" = a child AT Y* (M:925-946); flight list *Set supertracker to 1XYZ* (M:1026-1029) | action `supertrack` + `goTo` (R:574, 696-728, 757-788); **point the tracker** + target picker (O:764-830) | `A pointer <id>` → **RULED replaced by `A activate <childID>`** (D §13:373-401) | SC already-ruled: *child→child = activate* | in code as goTo; advisory rules the pointer form out |
| A37 | "the chain closes here" (no target) | child | — | `goTo = nil` *closes* (R:707-709); **nothing (closes)** (O:795) | — (`close` in D §9 means something else — C17) | — | in code |
| A38 | "run the action on start / update / complete of the stage" | child | — | `SetChildFireOn` (R:790-800) — **no UI caller** | — | — | in code (no door) |
| A39 | "this child wears the word 'kill'" (icon) | child | *the icon is a child's, the palette is ours* (M:824-831); *nothing writes it* (M:1206-1211) | `SetChildIcon` validated against `Map.Palette()` = `{"kill"}` (R:655-676; MP:1168-1176) — **no UI caller** | — | — | in code (no door) |
| A40 | "this child must wait for those children first" | child | — (*sequence as DISTANCE, never an execution-order rule*, M:1044-1049) | — | `requires: [ids]`, static DAG (D §4:110-123) | SC S5/S7: *both, and a way to express it* | designed only |
| A41 | "reaching this child hands the arrow to that child" | child | — | — (goTo is the nearest) | `A activate <childID>`; listen edges; *deaf until told to listen* (D §13:380-401) | — | designed only |
| A42 | "when the arrow should let go" | child / pointer | — | — | `close: arrive \| lead-in`; lure defaults lead-in (D §9:173-197) | SC already-ruled: *clear is an authored condition* | designed only |
| A43 | "this listens for a boss death, named from the run's engaged names" | child / beacon | `unit:death:<boss>` — a different AXIS; a beacon arms the listener; two sources validate (M:1443-1509) | — (capture holds names, RT:96) | entity kind `boss`, name *picked never typed* (D §11:236-257, §13:357-363); boss sync (T §3:65-70) | — | designed only |
| A44 | "put a personal note here — mine, outlives every route" | note plane (map) | two lanes: *for me* on the MAP (M:566-574) | `AddNote`, note plane per mapID (R:1095-1138); **Create note** (P:194, 356-366) | — | R:1099-1103 never travels | in code |
| A45 | "the text of my personal note" | note | — | `text` via `SetName` (R:307-321) | — | — | in code |
| A46 | "delete this note / this child" | note / child | — | `DeleteNote` (R:325-331), `DeleteChild` (R:466-475); popup (O:381-389) | — | — | in code |
| A47 | "this run is worth X" (name, comment a run) — curation as valuation | run (evidence, not route) | *naming and commenting ARE the curation* (M:653-662) | Rename / comment / Delete a run (E:329-362, 252-281) | — | — | in code |
| A48 | "show me only these kinds / this window / the whole run" (view state, not authored) | run view | *curation edits the view, never the capture* (M:668-679) | six kind ticks + all, envelope/window, peek/latch, play, track (E:115-122, 368-608) | — | — | in code |

_48 rows. Rows A28-A30/A38 have no consumer or no door; rows A18, A21 are the two "named as an answer, no field" cases (see E4)._

---

## E2. READER RECEPTIONS

| # | the reader receives… | appears / disappears | model word | code word | advisory / target / scoping / router word | cited | status |
|---|---|---|---|---|---|---|---|
| R1 | the arrow, set on the current stage's on-ramp | on stage ENTRY; re-set when a child action fires within the theatre | supertracker / tracker; *direction crosses stages on ENTRY* (M:928-957); understanding not world (M:254-258) | none (`BeaconAt` has no caller, S:13-14) | pointer — *a HEADING, not a waypoint chain* (D §10); *the arrow… the play space is that way*; pin is a slot you write to (RT:85, 88) | S:27 on-ramp | designed only |
| R2 | the arrow lets go | at close (arrive R_close / lead-in) and always at stage teardown; terminal release at finish | — | — | `close` (D §9); *terminal release is a requirement, not manners* (RT:85) | SC: clear is an authored condition | designed only |
| R3 | the arrow re-asserted if something else took it | on map change / divergence, rate-limited | — | — | heartbeat, *reinforcement never arbitration* (RT:87; D §6:156-158) | T §1 death pointer: last write wins | designed only |
| R4 | the note for the beacon they reached, in the readout box | on ARRIVAL — *the world tells* (M:393-399, 412-420) | *ONE SENDER on the driver, no ladder* (M:310-319); the box holds a stranger's text (M:277-290) | none | note slots last-writer-wins across satellites (D §4:105-108); ≤ ~200 chars (T §4:89); SC S9 *both* | — | designed only |
| R5 | the note gone when it no longer applies | on stage advance / on leaving a `while` trigger | — | — | *gone when it did not apply* (T §7:124); teardown on advance (D §3:74-76); `while` wipes on exit (D §4:101) | — | designed only |
| R6 | the stage advances (ratchet) | when the acceptance is reached | ratchet `max(index, outcome)` (M:716) | `Outcome` (R:1067) — evaluator not built | *within reach → advance* (S:28); completor fires (D §3) | — | designed only |
| R7 | a skip counted, not undone (maxSeen) | on reaching a later stage out of order | three registers — *the order still guides you from the beginning* (M:961-983) | — | SC §R S6 **ratchet + maxSeen tracked, skip expected**; K jump (D §2) | — | designed only |
| R8 | snapped to stage N (set / boss resync) | on a `set` child or a boss death | escapement; *bosses a cheap set:stage correction* (M:984-993, 1463-1474) | `setStage` (R:623) — position form | hard resync (D §2:47-49); recovery beacon (SC §R S6) | — | designed only |
| R9 | "done" | last stage satisfied | — | — | *finish* (S:29); terminal release (RT:85) | — | designed only |
| R10 | a line in chat, in their name, that they consented to | on the authored trigger; only if the driver-side tick is on; never while Curation/Promotion is open | announce (M:456-483) | none | — | M:262-266 *describes, never instructs others* | designed only |
| R11 | a distance-to-route number when off every listen range | while outside; *a number, never a reroute* | — | — | off-route readout (D §2:53-54) | — | designed only |
| R12 | NO grade, NO pack count, NO "you missed one" | never | *no judgement of a route* (M:1419) | — | R-c no auto-grading (D §1:30-31); T §6:109 | — | ruled out (deliberate absence) |
| R13 | an arrow back to where they died | on DEATH; current lure re-written on ALIVE; reader's option, off by default | — | — | death location pointer (T §1:37-45); SC S15 **later** | — | designed only (later) |
| R14 | nothing, until they SELECT a route and ARM it | — | *a run is ARMED by a person* (M:524-529) | — | inert until selected (T §5:93-105); SC F-ii **YES select + arm required** | — | designed only |
| R15 | a way to correct the index by hand | when the ratchet is wrong | *the driver will need a way for the player to CORRECT the index* (M:1004-1006) | — | S:43 OUT of v1; SC already-ruled *reload = user recovery (manual seek)* | — | designed only |
| R16 | the route remote — go, stop, and what it reports | spawned from Promotion | — | — | seventh surface (S:72-95) | — | designed only |
| R17 | (author as reader) the walk: a sprite over a run + a timeline of what fired | in the editor, paced by `play` | THE WALK (M:117-237); the count = how many of N runs each detector fired for (M:199-204) | `walk.lua` removed (M:234-237); `play` pacer exists (E:754-804) | *push-pull fitment* (D §11:268-276); SC S4 *walk nodes and their triggers on a data set* | — | designed only |
| R18 | (author as reader) a test driver cycling nodes near you | in-game, inside Dungeon Run | — | — | SC S4/S10; T §9 step 4 | — | designed only |
| R19 | hover: identity + state of a point | on hover, gone on move | *hover IDs, click holds* (M:354-366) | `Map.Describe` → tooltip (MP:1084-1133, 1599-1629) | — | — | in code |
| R20 | the beacon's three answers: *on-ramp X · ratchets when found / nothing ratchets* | while a beacon is selected | three answers (M:637-649) | `answersFor` (O:159-185) | — | R:874-876 *author freely, publish honestly* | in code |
| R21 | running order, `free:` gaps, `-> N` outcomes, match count | while a route is loaded | *we tell and trust* (M:742-746) | P:115-153; O:254-257 | — | — | in code |
| R22 | *target is gone* / *nothing (closes)* | on a dangling or empty goTo | — | O:336-341; `BrokenLinks/Cycles/Heads` (R:912-951) | — | — | in code |
| R23 | the test line — what the act just did (`move-z`, `child-here`) | on the act, never before | *emit on the act* (M:404-406) | `NS.Tests.Register/Run` (O:49-101, 454-458) | — | — | in code |
| R24 | text from a stranger rendered safely (no fake links / icons) | always | *no input reaches an interpreter* (M:422-454); escape at import (M:337-352) | ☐ NOT YET (M:451) | — | — | designed only (open hole) |
| R25 | the beacon always visible; children faded, restored on click | editor | (M:774-787) | none | — | — | designed only |

_25 rows._

---

## E3. CONFLICTS — same intent, different structure or words; or one source rules out what another allows

| # | intent | source A | source B | resolution on file, if any |
|---|---|---|---|---|
| C1 | what the parent beacon's own position IS | M:585-596 *a LABEL POSITION… nothing downstream may consume it* | D §3:71-76 *THEATER: parent's position + R is the SCENE = the arm zone* | SC §R S2 → (a) label + *scene manager*; broad listen stays *a config* (D §13:392-397) |
| C2 | who speaks for a stage (on-ramp / lure) | R:844-857 declared, exclusive, **no default**; `OnRampOf` falls back to the beacon | D §1 R-e *the first child created IS the lure… the author configures nothing*; `lure:true trigger:on_enter` (D §5:131) | none — word (on-ramp vs lure) and defaulting both differ |
| C3 | moving the arrow inside a theatre | R:696-788 action `supertrack` + `goTo` (target ID, resolved to a POSITION at export, R:529-532); M:925 *"go to Y" = a child at Y* | D §13:373-401 **RULED: `A pointer <otherID>` leaves the table; child→child = `activate`** (the reached child hands the arrow; target points to itself); D §13:405 *pointers target IDs, never a copied xyz* | ruled in D/SC; code unchanged |
| C4 | ordering inside a theatre | M:1044-1049 *a set of STANDING CONDITIONS… the author expresses sequence as DISTANCE, and we never need an execution-order rule*; R:509-532 order derived from custody, enter-from-any | D §4:110-123 `requires` (DAG), `sequence` = each requires the previous | SC S7 *Neither. Programmatic primitives… both and a way to express it*; SC S5 define the model first |
| C5 | refuse or tell | M:742-746, R:1014-1022 *no validation on authoring* | D §4:121-123 `requires` DAG *checked… REFUSED — authoring mistakes die before a frame ticks*; D §5:143 exactly-one-lure check | SC S4 **tell and trust** |
| C6 | repeat suppression | R:631-651 `ifUnseen` default TRUE for every child, but the chip is shown ONLY for `set` (O:310-320); M:1000 *a REPEAT guard* | D §4:99-104 `mode: once \| while` — an entity fact on every child, `while` new | SC S5 notes `while` has no prior term; not decided |
| C7 | reaching a later stage out of order | M:961-983 three registers — clip writes `maxSeen`, ratchet untouched (D's jump is what M calls *clip-through*) | D §2:44-46 forward listen K → *jump; intermediates SKIPPED* | SC §R S6 **ratchet + maxSeen tracked; skip is EXPECTED** (advances AND records) — a third reading of both |
| C8 | who writes the driver's note box | M:316-319 *ONE SENDER… no ladder problem at all* | D §4:105-108 shared slots, *last-writer-wins* across satellites | SC S9 *Both* |
| C9 | where a note lives | R:569-574, 802-812 per-child note REMOVED — *a note is a CONSUMER several children reference*; M:1017 flight list *Set note Y* | D §5, §13:367-368 `A note "…"` per child action | SC S8 (v2) *Agreed* — to which shape is not stated |
| C10 | what `4.1` means | M:727-740, R:172-184 a BEACON between 4 and 5 | D §3:73 *children live under its identity (4.1, 4.2)*; D §13:386 chains *never 3.1/3.2* | none |
| C11 | the word for the thing that fires | M:141-148, 1443-1461 *detectors* | D §0:13-14 *There are no "detectors" — pre-configured positions that trigger pre-configured responses* | none (A5 rename table lists it) |
| C12 | drag a placed object | M:96-102, R:274-282 free placement, origin kept | D §12:314-317 *"moving" is not a drag to a free point, it is re-seating onto another read* | SC S1 **free placement** |
| C13 | the words `start · update · complete` | R:560-567 detect ROLES (what it does to the index) | R:790-800 `fireOn` (WHEN the action runs) — same three words, second meaning, in one file | none; `fireOn` has no door |
| C14 | `arm` | M:524-529 a RUN is armed by a person; capture vocabulary | D §2-3, §11 *arm zone · armed stage · arm CLEU*; SC F-ii *SELECT a route and ARM* | none — one word, three referents |
| C15 | where reach lives for a childless beacon | M:609 shape/reach are child words; code has no beacon radius (R:688 child-only) | S:66-68 *inside those only the supertracker y/n and the reach* on the childless face; D §3:69 `position + R ±H`; T §3:64 | none — the field does not exist |
| C16 | `close` | R:707-709, O:795 *nothing (closes)* = the CHAIN ends | D §9 `close: arrive \| lead-in` = when the ARROW lets go | none |
| C17 | the walk | M:155-193 in-game, paced by `play`, *an addon feature not an instrument*; offline = a second evaluator | D §11:268-276 chunked in EDITOR; W-tests via desk `walk.py` (A5 rename table row 1) | SC S12 new samples first; SC S4 walk in the editor |
| C18 | do datasets travel | D §12:290-291 *the dataset is part of what travels* (struck) | M:206-227 runs stay home; T §5 out of band | SC S11 marked stale |
| C19 | consumer exists? | M:1420-1422 *No consumer… the recorder records* | S:11-19, T §9 the consumer is the focus | superseded by S/T (chronology, not a live disagreement) |
| C20 | who may advance the stage | R:581-599 any child with `complete`; nothing about a `set` from an event | D §3:82 *only a child TYPED as a completor*; D §13:356-357 a `boss` entity with `A complete`; D §11 boss → SET *both directions* | none |

_20 conflicts._

---

## E4. GAPS — named as wanted, no expression in any source

| # | intent | named where | what is missing |
|---|---|---|---|
| G1 | a note the reader receives | M:643, 268-290; T §4; D §13; SC S8 | no field, no setter, no surface (per-child form removed R:802; shared-consumer form never built) |
| G2 | reach on a childless beacon | S:66-68; D §3:69; T §3:64 | no beacon-level radius/band anywhere in code |
| G3 | the announce message and the runner's consent tick | M:456-483 | no field, no tick, no send path |
| G4 | export / import string | M:571; D §12; T §5; SC S11 | no serialiser, no `schema_version`, no import door |
| G5 | an icon on a child | M:824-863, 1206-1211 | `SetChildIcon` exists, no control calls it |
| G6 | when a child's action runs (`fireOn`) | R:790-800 | no control calls it; no model section names it |
| G7 | per-child opacity from the beacon; child roster tab | M:774-787, 888-899; SC §R S2 | no code |
| G8 | the player correcting the index by hand | M:1004-1006; SC *manual seek* | a requirement with no design of its surface |
| G9 | far-stage policy | M:995-999; S:105-109; SC S13 | OPEN everywhere — *decide once we have something working* |
| G10 | picking a boss name from the run's engaged names | D §13:357-363; T §3:74; RT:96 | capture holds names; no authoring list, no child kind |
| G11 | flagging / ladder / one-or-many for the readout box | M:388-410 | three questions left open |
| G12 | escaping stranger text at import | M:446-451 ☐ | not built |
| G13 | does a stage increase always carry a direction | R:730-755 OPEN (M:928-957 answers *entry points, exit does not* — the code comment is not updated) | reconciliation not recorded |
| G14 | a settled vocabulary | SC S3 *vocab is its own audit / research*; SC S5 | this audit is the input; nothing decided |
| G15 | `while` (level-triggered) | SC S5 *no prior term* | no model section, no code |
| G16 | a listen edge / activation drawn on the map | D §13:380-401 | no surface for drawing an edge; goTo picker is the nearest |
| G17 | the route remote's controls | S:85 *Go, stop, and whatever it reports* | rows not declared |
| G18 | the walk's exact form (in-addon) | M:199-204; D §8:420-421 | *not decided here* |

_18 gaps._

---

## E5. CANDIDATE VOCABULARY — the plainest existing word per row (candidate, not decided)

_Chosen from words already on file; the source it comes from in brackets. Where two sources
disagree the pick is the one that reads in a sentence a route author would say._

| row | candidate | from | not chosen |
|---|---|---|---|
| A1/A12/A25 | **name** | code | label (M sheet — a question, not a field) |
| A2 | **map** (dungeon) | code `mapID` | — |
| A4 | **share** (export / import) | M:571 exportable | package (D) |
| A5 | **announce** | M | — |
| A6 | **listen ahead** (K) | D forward listen | far-stage |
| A8 | **beacon** | all | theater (D), anchor (M) |
| A9 | **stage** | all | — |
| A11 | **match** | code / M | — |
| A13 | **move** | code chip | re-seat (D), place (R fn) |
| A14 | **advance** | code / S | complete (D) |
| A15 | **go to stage** | code | checkpoint (M/R), set (D — reserved for A27) |
| A16 | **come here** | M / R:928 | lure (D), on-ramp (M) |
| A17 | **done when found** | M:645 | self-completing (D), acceptance (R) |
| A18/A34 | **reach** (radius) · **band** (up / down) | M:609 / code | R ±H (D), tolerance (T) |
| A19 | **theatre** | M / R | scene / arm zone (D) |
| A20 | **fade** | M:759 | opacity |
| A21 | **note** | all | — |
| A23/A24 | **child** | M / code | satellite · entity (D) |
| A26 | **stage complete** | code dropdown | completor (D), acceptance / satisfier (R) |
| A27 | **set stage** | code dropdown | resync (D), escapement (M) |
| A28/A29 | **start of stage** · **updater** | code dropdown | — |
| A31 | **only if unseen** | code chip | once (D) |
| A32 | **while inside** | D `while` (only source) | — |
| A33 | **radius** · **trip wire** | code dropdown | — |
| A35 | **the way in** | code chip | on-ramp (M), lure (D) |
| A36 | **point the tracker** | code dropdown | supertrack (R), pointer (D), activate (D — different mechanism, see C3) |
| A37 | **closes** | code | — |
| A38 | **fire on** | code | — |
| A39 | **icon** (word from the palette) | M / code | — |
| A40 | **requires** | D (only source) | — |
| A41 | **activate** | D (only source) | — |
| A42 | **let go** | D §9 F-ii wording *give the tracker back* → close | close (collides with A37) |
| A43 | **boss death** | M / D | CLEU, unit:death (M hopes) |
| A44 | **personal note** | code / M | for-me lane (M) |
| A47 | **comment** | code | — |
| R1 | **arrow** | T / M / D | supertracker (M/R), pointer (D), tracker (code) |
| R4 | **note** (in the readout box) | M | — |
| R6 | **advance** | S / M | — |
| R7 | **skip** | SC S6 | clip-through (M), maxSeen (M/SC register name) |
| R8 | **set** | M / SC | hard resync (D) |
| R9 | **done** | S | finish |
| R10 | **announce** | M | — |
| R11 | **off route** | D | — |
| R14 | **select · arm** | SC F-ii | — |
| R15 | **correct** (the stage) | M:1004 | manual seek (SC) |
| R16 | **route remote** | S | — |
| R17 | **walk** | M / SC | fitment (D), W-tests |
| R18 | **test drive** | SC S1 *test drive mode* / T §9 *test driver* | — |
| R19 | **hover** | M | tooltip |
| R20 | **answers** (on-ramp · ratchet) | M / O | — |
| R21 | **running order** · **free** · **match** | P / O | gaps (R fn) |
| R23 | **test line** | O | response box (M:330) |

_Not chosen anywhere: `detector`, `satellite`, `entity`, `completor`, `lure`, `scene`, `pointer`,
`R`, `±H` — each has a plainer twin already in code or the model. Marked candidate; SC S3 says the
words follow the behaviours, so none of this decides._
