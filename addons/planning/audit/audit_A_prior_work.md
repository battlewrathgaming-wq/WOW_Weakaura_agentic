# Audit A — prior work vs the driver-analysis arc (2026-08-17)

_Independent audit, from files only. Repository root relative paths. "Prior" = state before
`§241` (`e17cef1`, 2026-08-16 23:53, the brief). "Arc" = `driver_analysis_brief.md` ·
`driver_analysis_asklist.md` · `driver_design_advisory.md` · `driver_walk_acceptance.md` ·
`driver_walk_result.md` · `driver_posture.md`, plus arc-day edits to `ROUTER.md`,
`dungeonrun_model.md` (§243, §258) and `capture.lua`/`core.lua`/`store.lua` (§248/§249/§254/§264).
Where a "prior" file was itself edited during the arc, the row says so. Line numbers are as of
HEAD `e073820`; ROUTER prior state taken from `git show 2f8f6aa:operations/ROUTER.md`._

Abbreviations: **M** = `addons/planning/dungeonrun_model.md` · **S** = `addons/planning/mvp_scope.md`
· **R** = `operations/ROUTER.md` · **L** = `addons/planning/satnav_ledger.md` ·
**B** = `driver_analysis_brief.md` · **A** = `driver_analysis_asklist.md` · **D** = `driver_design_advisory.md`
· **W** = `driver_walk_acceptance.md` · **X** = `driver_walk_result.md` · **P** = `driver_posture.md`.

---

## A1. INVENTORY — what the project held before the arc

### Code capabilities

| item | where | statement |
|---|---|---|
| Set the supertracker (ladder-respecting call) | `COA_Landmarks/beacon.lua:107-129` | `Beacon.Pin(id)` → `SuperTrackerUtil.SetSuperTrackedPosition(x,y,z,mapID)`; keeps own copy (AC-18); installs poll only while pinned (`:125`) |
| Clear / release | `beacon.lua:132-136` | `Beacon.Clear()` nils state, removes `OnUpdate`, calls `SuperTrackerUtil.ClearSuperTrackedPosition()` |
| Release on arrival, never reclaim | `beacon.lua:1-8`, `:103-106`, `:195-201`, `:213-220` | "occupy on an explicit pin -> release on arrival -> NEVER reclaim"; pin is ALWAYS a user act (AC-12); slot lost → do not retake (AC-19) |
| Ownership detector via the client global | `beacon.lua:85-93` | `Beacon.OwnsSlot()` compares `_G.SUPER_TRACKED_POSITION.x/y/mapID` to the pinned landmark |
| Yield to quest flow | `beacon.lua:260-266` | `hooksecurefunc("SelectQuestLogEntry")` → `Clear()` |
| Distance-paced poll (throttler) | `beacon.lua:40-62`, `:203-211`, `:234-239` | `nextIn = max(POLL_MIN, min(POLL_MAX, (dist − tier)/MAX_CLOSING_SPEED))`; `POLL_MIN 0.20`, `POLL_MAX 2.00`, `MAX_CLOSING_SPEED 30`, `ARRIVAL_HOLD 1.00`; interval check before any API call |
| Arrival condition (three guards) | `beacon.lua:167-190` | `GetTargetState()` not nil/0 · player mapID == pin mapID (AC-25) · engine `dist <= TierYards(tier)`; "⚠ Never compute your own distance" (`:181`) |
| Sustained-state debounce | `beacon.lua:213-220` | arrival must hold `ARRIVAL_HOLD` (AC-26); reason: loading screen gives momentary Invalid |
| Cannot-guide detection | `beacon.lua:143-160` | mapID mismatch → "map" (engine refuses, F38); `dist > 1500` → "range" (client's cut) |
| Tiers | `COA_Landmarks/store.lua:40-55` | zone 300 · approach 100 · interact 5 yd; default `interact` |
| Capture: 1 Hz sampler, in-instance only, combat too | `COA_DungeonRun/capture.lua:42`, `:336-367` | `SAMPLE_EVERY = 1.0`; `OnUpdate` installed by `Arm`, cleared by `Stop` (`:448`, `:473`); zero persistent OnUpdate |
| Capture events | `capture.lua:681-705` | `PLAYER_REGEN_DISABLED/ENABLED`, `PLAYER_ENTERING_WORLD`, `ZONE_CHANGED_NEW_AREA`, `PLAYER_DEAD`, `INSTANCE_ENCOUNTER_ENGAGE_UNIT` |
| Boss engagement = event + token poll | `capture.lua:248-258`, `:589-593` | `boss1..boss5` via `UnitExists`/`UnitName`; names, never encounters (`:234-237`) |
| Death attribution from DeathRecap | `capture.lua:199-228`, `COA_DungeonRun/DRIVER_CONTRACT.md` | `attacker` + `isPlayer` filter, only at `PLAYER_DEAD` |
| Player pin (capture) | `capture.lua:541-546` | `Capture.Pin()` → marker kind `pin` with pull index |
| Point schema (both clocks, fraction, floor) | `COA_DungeonRun/store.lua:154-170`, `:117-127` | `x,y,z,mapID · mapX,mapY,mapC,mapZ · floor · zone,subZone · t,gt` |
| Fraction→world runtime fit, per map per floor | `COA_DungeonRun/calibrate.lua:20-47`, `:145-178`, `:203-269` | 6-param affine least squares; refuses on spread/collinearity; ABSENT for unrun dungeon; session cache |
| Beacon inherits PLACE only | `COA_DungeonRun/routes.lua:48-60` | whitelist `x,y,z,mapX,mapY,mapC,mapZ,mapID,floor`; EVENT fields never carried |
| `z` inherited, never computed | `routes.lua:29-31`, `:260-262` | "z in particular is INHERITED AND NEVER COMPUTED (§25.2)"; drag does not touch z |
| Drag = new-else-original; world xy via calibration | `routes.lua:274-305` | `Place(p, atX, atY, mapID, floor)` resolves `atWorldX/Y` via `Calibrate.ToWorld` or leaves ABSENT |
| Beacon id, stage, editable stage, no validation | `routes.lua:214-230`, `:1023-1029` | monotonic per-route id; duplicate/fraction/out-of-order stages allowed |
| Child roles / shapes / actions | `routes.lua:567-574` | `ROLES = start·update·complete·set` · `SHAPES = radius·wire` · `ACTIONS = supertrack` (note removed §91) |
| Only `set` exclusive; on-ramp exclusive | `routes.lua:581-618`, `:844-857` | two `complete`s legal; `set` clears siblings; `onRamp` clears siblings |
| `ifUnseen` repeat guard, default true | `routes.lua:631-651` | by-exception storage (only `false` stored) |
| Reach fields written, never evaluated | `routes.lua:685-694` | `SetChildReach(child, radius, up, down)`; band asymmetric; no clamp/floor |
| goTo custody chain, derived order, graph checks | `routes.lua:509-532`, `:764-788`, `:912-955` | `SetChildGoTo`, `GoToTarget`, `Heads`, `BrokenLinks`, `Cycles`; "AUTHOR WITH AN ID, FLATTEN TO COORDINATES" |
| `fireOn` — action time independent of detect role | `routes.lua:790-800` | `start·update·complete` |
| On-ramp of a beacon; acceptance of a beacon | `routes.lua:862-868`, `:893-902` | falls back to the beacon itself when childless |
| Outcome ratchet | `routes.lua:1000-1008`, `:1067-1070` | `index = max(index, outcome)`, `outcome = self+1` default |
| `BeaconAt(id, index)` — the consumer's read, no caller | `routes.lua:1085-1093` | first beacon at-or-above index |
| Playback pacer | `COA_DungeonRun/editor.lua:776-810` | `STEP_EVERY = 1.0`; OnUpdate exists only while playing |
| Slash surface (prior verbs) | `COA_DungeonRun/core.lua:100-229` | `arm pin stop map edit list status probe ui delete` (+ arc-day `armdev`, `testpin`) |
| Stage-increase-carries-direction: OPEN in code | `routes.lua:730-755` | "Recorded as OPEN rather than chosen" (2026-08-15); later settled by M §234 |

### Facts (prior; ROUTER at `2f8f6aa` unless noted)

| item | where | statement |
|---|---|---|
| Position API | R (prior) · `store.lua:155` | `GetCurrentPlayerPosition()` → `x,y,z,mapID`; mapID = continent/instance |
| Map-boundary decline = Invalid + `0.00`, not nil | R prior `:95` · L F38 `:111` · `beacon.lua:13-21` | zero satisfies every radius test; row ended "**never compute your own**" |
| Engine distance is 3D, 1e-5 | L F28/F39 `:99`, `:112` · `beacon.lua:179-181` | 1,758 samples |
| One slot; Position outranks Quest; nothing passive gives it back | L F24 `:93` · `beacon.lua:3-8` | `SUPER_TRACKED_POSITION` = "a plain global holding one `{x,y,z,mapID}`"; CVar-off nils it (F41 `:115`) |
| Prior ROUTER row said the opposite | R prior `:84` | "There is no ownership to arbitrate — a player who wants it back just opens their journal" |
| Heartbeat may be needed; reinforcement never arbitration | R prior `:85` | Battlewrath: "not a race" |
| `SuperTrackerUtil` not `C_SuperTrack.*` | R prior `:86` · L F24 ① | direct call skips the ladder |
| Engine arrival radius ~5.5 yd, unsettable | L F31 `:102`, F37 `:109` | (5.46, 5.59) |
| Client cuts 727 / 1500 yd; engine tracks to 3,742 | L F22 `:90`, F32 `:103`, F35 `:107` | our readout uncapped |
| `SUPER_TRACKING_CHANGED` event on target change; state is polled | L F25 `:94` | "event for TRANSITIONS, poll for STAGES" |
| Cross-zone never the problem; range and map are | L F30 `:101`, F36 `:108` | mapID is the continent |
| DeathRecap, boss engage, `UnitExists` returns 1, PLAYER_ENTERING_WORLD on reload | R prior rows · `capture.lua` | as cited in code |
| Export path: own serializer, LibDeflate present via WA, one package/unpackage door, zero-trust both ends | L §5.9 `:862-1160`, `:1020` | "WeakAuras DOES ship LibDeflate" |
| Two addons, two formats (export/import lifecycle) | L §5.10 `:1426-1457` | scoped |

### Rulings (M and S, prior unless noted)

| item | where | statement |
|---|---|---|
| Capture is the only spawn; gate is on ORIGIN not POSITION; dragging afterwards is yours | M `:82-102` | "A beacon must come from a capture; where you move it afterwards is yours" |
| A run is a surface read; store holds LEGS so a walk test is segment-against-reach | M `:104-113`, `:229-232` | "the test is segment-against-reach, not point-against-reach" |
| THE WALK: sprite over run data, in-game, paced by `play`; offline = second implementation; addon feature not instrument; route travels, runs stay home | M `:117-237` | "AN OFFLINE VERSION WOULD RE-IMPLEMENT THE TRIGGER LOGIC" (`:164`) · "They don't have our bench" (`:182`) · "runs never need to travel" (`:222`) |
| We inform, never act; announce is the edge | M `:241-266` | |
| Readout box: driver = ONE SENDER, no ladder; sanitise at import; no input reaches an interpreter; rendering `\|` hole open | M `:268-352`, `:422-454` | "ONE SENDER ON THE DRIVER... no ladder problem at all" (`:316-319`) |
| A beacon is a THEATRE; anchor position is a LABEL POSITION, nothing downstream may consume it | M `:578-596` | "nothing downstream may consume it" (`:594`) |
| Children are the everyman surface: detect / condition / instruct vocabulary | M `:598-617` | `shape·reach·reach.up·reach.down·unseen` / `role·stage·stage match·ramp` / `action·target·outcome` |
| Children sample-sourced, absolute x/y/z | M `:622-633` | |
| Three answers: on-ramp · note · ratchet | M `:637-649` | |
| Stage ordinal; fractions; no validation; only `set` exclusive | M `:712-746` | |
| A beacon points to SELF; complexity is children; direction crosses stages on ENTRY; exclusivity is structural | M `:923-957` (§234, 2026-08-16) | "exit never points and entry always does" (`:956`) |
| Stage state = three registers (set / ratchet / maxSeen); clip-through and stubbornness | M `:961-1011` (§235) | "a clip writes maxSeen and leaves the ratchet alone" (`:976-977`) |
| Far-stage policy OPEN; instrument = sprite walking a real run | M `:995-999` · S `:104-109` | "build-to-lookable, not an ask" |
| Driver needs a player index-correction | M `:1004-1006` | |
| Flight list: compile target; steps self-contained; driver stateless; not a program counter; sequence as DISTANCE, no execution-order rule | M `:1015-1053` | "keeps the driver stateless — no lookups, no references" (`:1039`) · "we never need an execution-order rule" (`:1049`) |
| Deliberately absent: no consumer; a route runner is a separate addon | M `:1412-1422` | "A route runner is a separate addon with its own remote" |
| Hopes: `unit:death:<boss>`; bosses = cheap `set:stage` resync | M `:1443-1474` (§235) | prior; §258 block at `:1476-1508` is arc-day |
| MVP cut: arm · ratchet only · on-ramp · off-ramp · finish; children/notes/CLEU/maxSeen/correction/flight-list OUT | S `:23-49` | |
| ORDER: overhaul FIRST, then the driver | S `:53-68` | "1. the overhaul 2. the driver" |
| Route remote = seventh surface, spawned from Promotion, no typed commands | S `:72-95` | |
| Wipe SVs before first run | S `:97-102` | |

---

## A2. RE-DERIVED — arc worked out what prior work already held

| # | the arc | prior | rating |
|---|---|---|---|
| 1 | Segment-vs-cylinder test as the answer to the grazing pass — A H0-a `:293-307`, H2 `:372-380`, H4 `:391-414`; W1.1 | M `:229-232`: "a detector can be passed between two samples... the store holds LEGS... segment-against-reach" | harmless duplication (arc adds closed form + fixtures; never cites M `:229`) |
| 2 | Tracker global carries the target world position; "Nobody had looked before" — `capture.lua:98-105` (§249b), R `:97` (§253), A F-i design "the run knows the coordinates because it set them" (B `:44-47`) | L F24 `:93`: global holds `{x,y,z,mapID}`; `beacon.lua:88-93` reads `.x .y .mapID` in shipping code | **produced a divergent answer** — the arc stated the prior state wrongly ("nobody had looked") and B `:44-47` built the pin-and-hold rationale on the gap |
| 3 | Ownership / divergence detector: compare engine `sd` to own distance — A H5 `:416-432`, W2.2 | `beacon.lua:85-93` `Beacon.OwnsSlot()` (global compare); L F25 `SUPER_TRACKING_CHANGED` event on target change | harmless duplication (different mechanism; prior ones not mentioned) |
| 4 | Position outranks Quest; nothing passive gives it back — A F-ii `:219-228`, R7 `:1027-1030`, R `:84` correction | L F24 `:93` (2026-08-12); `beacon.lua:1-8` header | cost time — the §240 ROUTER row (`2f8f6aa:84`) contradicted F24 and Landmarks; A R7 restored it via F24 |
| 5 | Height by construction — R-b (D `:28-29`, A `:330-336`), "my earlier drag-z candidates withdrawn" | `routes.lua:29-31` "z INHERITED AND NEVER COMPUTED (§25.2)"; `:260-262`; M `:622-633` | cost time — candidates proposed and withdrawn against a rule already in code |
| 6 | Beacon points to SELF; only lures — D §13 `:364-369` "RULED (Battlewrath, 2026-08-17)"; R-e one lure defaulted (D `:34-35`) | M `:923-957` (§234, 2026-08-16); `routes.lua:844-868` on-ramp exclusive, beacon fallback | harmless duplication (re-ruled a day later; D `:366` does cite the flatten denormalisation) |
| 7 | Two radii = two steps on one position — D `:365-367` | M `:1033-1037` | harmless (cited) |
| 8 | Bosses as authoritative SET / hard resync — D §2 `:47-49`, §5 `:136`, §11 | M `:1463-1474` "bosses become a cheap set=stage correction"; `routes.lua:565-566` `set` is the only backwards move | harmless duplication (D `:49` calls it "the correction path v1 excluded"; M already placed it) |
| 9 | Non-positional trigger `cleu <boss name> dies` — D §5 `:136`, §11 | M `:1443-1461` `unit:death:<boss>` (§235) | harmless duplication |
| 10 | Route as instruction set / dumb walker / compile at author time — A H0-b ruling `:326-329`, D §0, §11 `:278-283`, §13 | M `:1015-1053` flight list, "the flatten is a TRANSFORMATION" (`routes.lua:529-532`) | harmless in principle; **divergent in detail** (see A4 #4, #5) |
| 11 | Overwrite is the handover; release only in the terminal case — W6 `:185-216` (§288), X `:494-497` | M `:950-957` "exit never points and entry always does"; `beacon.lua:132-136`, `:213-220` release-on-arrival ships | cost time — A H16 `:762-764`: "I built W6 too large; the Bench shrank it correctly" |
| 12 | mapID equality as the detection gate — A H0-c `:338-343` | `beacon.lua:175-177` (AC-25); listed in A B3 | harmless (cited) |
| 13 | Compile-time graph checks: no cycles / reachable / no orphans on `requires` — D §4 `:120-122` | `routes.lua:912-955` `Heads`, `BrokenLinks`, `Cycles` on `goTo` | **produced a divergent answer** — same checks re-specified over a different primitive (`requires` vs `goTo`) |
| 14 | Route-wide unique IDs — D §13 `:344` | `routes.lua:212-213` "unique is in the sense of a route" | harmless |
| 15 | Player index correction as a control (manual seek) — A C-1 `:781-785`, G6 | M `:1004-1006` | harmless (cited by A) |
| 16 | Position gates the CLEU listener; generous radius free — D §2 `:50-51`, §11 | M `:1497-1508` (§258 block written arc-day; the `:1443` hopes prior) | not determinable which came first within the day |
| 17 | 5 yd default close radius — D §9 `:188` | `COA_Landmarks/store.lua:47` interact 5 yd; L F31/F37 engine 5.5 | harmless |
| 18 | Every pos is a COPIED READ, seed once — D §12 `:308-314`, §13 `:351` | M `:82-102`, `:622-633`; `routes.lua:48-60` PLACE whitelist | harmless duplication (see A4 #7 for the divergent half) |

---

## A3. OVERLOOKED — prior work the arc did not use

| # | prior | where | what the arc did instead |
|---|---|---|---|
| 1 | The walk is IN-GAME, paced by `play`; offline = a second evaluator that must agree with the first | M `:155-179`; `editor.lua:776-810` (`STEP_EVERY`, `TogglePlay`) | W0 `:25-26`: rule "written on the DEV DESK first (Python), then ported"; W7 makes the desk the golden. M `:164-167` is not cited in B/A/D/W/X/P |
| 2 | Sanitise at IMPORT; text reaches a SINK never a parser; `\|c \|T \|H` rendering hole open | M `:337-352`, `:422-454` | D §12 package/import (`:285-340`) specifies schema_version + integrity hash only; no mention of escaping or the rendering hole |
| 3 | Export path already scoped: own serializer, LibDeflate ships with WA, one door, zero-trust | L §5.9 `:862-1160`, `:1020` | D §12 `:337-339`: "which libs WA uses on this client = bench fact" — left as an open ask |
| 4 | Route travels, runs stay home; imported route × own runs is already the cross-person test | M `:206-227` | D §12 `:293-299` makes DATASET its own travelling economy (see A4 #8) |
| 5 | `SUPER_TRACKING_CHANGED` fires on target change | L F25 `:94` | A H5 heartbeat designs overwrite detection by divergence + timer; the event is not mentioned |
| 6 | CVar-off loss mode: tracking false, global nil, distance nil | L F41 `:115`; F24 ② | A H5 `:418-427` lists two loss modes (map boundary, silent overwrite/decline); CVar-off absent |
| 7 | `Beacon.OwnsSlot()` — an ownership check already shipping | `beacon.lua:85-93` | A H5 builds a new detector; A A1/B3 cite `poll()`/`arrivalConditionMet()` but not `OwnsSlot` |
| 8 | Order: overhaul FIRST, MVP unblocks it | S `:53-68` | A §K `:821-836` orders G1 driver → G2 capture → G3 remote → G4 overhaul |
| 9 | goTo custody chain and its checks (`Heads/BrokenLinks/Cycles`), `fireOn`, `ifUnseen` | `routes.lua:509-532`, `:764-800`, `:631-651`, `:912-955` | D §4/§13 design `requires`, `mode: once\|while`, `pointer <id>` → `activate`, without reference to the existing fields (D `:164` withdraws a `repeat` flag that does not exist in code) |
| 10 | Model's readout-box rulings for the driving life (one sender; arrival is the event; announce needs a flag) | M `:302-320`, `:388-420` | D §4 `:106-108` "shared note slots are last-writer-wins"; §2 off-route readout — neither cites M |
| 11 | Curation as adversarial corpus for the walk; count-of-N-runs summary shown IN THE ADDON | M `:150-153`, `:199-204` | W5.5 cross-fixture numbers exist (X `:259-265`) but land in `walk.py`, not the addon; M `:181-197` not cited |
| 12 | `Routes.BeaconAt` "at or above" and stage-as-label semantics | `routes.lua:1072-1093` | A C-5 `:796-798` raises fractional-stage ordering as a new port note |

---

## A4. CONTRADICTIONS — arc vs prior rulings/code (stated, not adjudicated)

| # | prior | arc | the conflict |
|---|---|---|---|
| 1 | "**never compute your own**" distance — R prior `:95`; `beacon.lua:179-185` "⚠ Never compute your own distance" (still in HEAD) | A H0-b ruling `:322-329` "detection uses our OWN positions"; R `:107` "that instruction is OVERRULED" | Landmarks code comment and the ROUTER row now state opposite rules; L F28/F39 cited by both sides |
| 2 | Offline walk = second implementation of the trigger logic; the walk is an addon feature — M `:155-197` | W0 `:25-26`, W7 `:264-275`: desk walk (`walk.py`) is the golden; Lua is the port; X `:118-206` W1 proven on the desk | direct conflict on where the reference evaluator lives |
| 3 | Anchor position is a LABEL POSITION; nothing downstream may consume it — M `:593-594` | D §3 `:71-73` theater's "position + R is the SCENE = the arm zone"; D §13 `:349` `B1 theater <read> 40 open` | the theater xyz is consumed as an arm-zone centre |
| 4 | Flight-list steps self-contained; driver STATELESS, no lookups, no references — M `:1039` | A H4 `:410` stores previous position + mapID + flag; D §4 spent-set, `requires` lookups; D §13 `:398-400` `E[i]`/`I[i]` arrays with O(1) lookups; hysteresis state (D §4 `:103-104`) | stateless vs stateful consumer |
| 5 | Flatten is the DESTINATION, not the start; v1 reads structure directly — S `:45` | A H0-b ruling `:326-329` "a route compiles at the desk... driver is a dumb walker"; D §11 `:278-283` consumer "computes NOTHING that could have been resolved at flatten time"; A §K G1 `:829` reverts to "flatten deferred, per scope" | the arc's own ruling and its gap list disagree with S and with each other |
| 6 | Clip-through is a failure the three registers fix: "a clip writes maxSeen and leaves the ratchet alone" — M `:969-979`; S `:26` ratchet only, no maxSeen | D §2 `:41-43` forward listen K=3: "any forward stage satisfied -> jump; intermediates SKIPPED, not done"; W5.2 | K-forward jumps the ratchet, which M names as clip-through; maxSeen is neither used nor deferred by D |
| 7 | Gate is on ORIGIN not POSITION; "where you move it afterwards is yours" — M `:96-102`; `routes.lua:274-282` `Place` drags to any `atX/atY` | D §12 `:311-314` "'moving' is not a drag to a free point, it is re-seating onto another read; without samples the tool does not offer the operation" | free drag (prior, in code) vs re-seat-only (arc) |
| 8 | Runs never travel; the 317KB payload problem never arrives — M `:206-227` | D §12 `:293-299` DATASET "its own string, its own import/export"; `:290-291` "the dataset is part of what travels" | runs stay home vs datasets travel |
| 9 | Driver readout has ONE SENDER, no ladder — M `:316-319` | D §4 `:106-108` shared note slots, last-writer-wins across satellites | one sender vs many writers |
| 10 | `note` action removed (§91); `ACTIONS = { "supertrack" }` — `routes.lua:569-574`; S `:40` note actions OUT | D §5 `:131-134` `actions: [ note \| pointer \| cleu_on \| complete ]`; D §13 `:357-359` `A note "come here"` | per-child note actions re-introduced (beyond v1, but against the §91 removal) |
| 11 | Sequence expressed as DISTANCE; "we never need an execution-order rule" — M `:1044-1049` | D §4 `:110-119` `requires`/`sequence`; D §13 `:371-392` activation chains as the ordinal form | an ordering primitive is added |
| 12 | Route runner is a SEPARATE addon — M `:1421`; seventh surface INSIDE DungeonRun spawned from Promotion — S `:72-95` | D §11 `:221-233` "The product is TWO addons... CONSUMER addon 2"; A §K G1 `:824` "THE DRIVER (Lua, in COA_DungeonRun)" | three placements across prior and arc; not reconciled in files |
| 13 | Order: overhaul first — S `:53-68` | A §K `:821-836` driver first, overhaul fourth | build order |
| 14 | Landmarks arrival = engine distance + state + hold — `beacon.lua:167-220`; W6 acceptance `:205-216` says the driver "reuses this" | D §9 `:174-188` close = own-position segment test at `R_close`, no state, no hold | the reused mechanism and the specified mechanism differ |
| 15 | Two stage-completes legal, any child satisfies — M `:719-721`; `routes.lua:581-598` | D §3 `:82-84` "Ownership stays single (the author designates it)... Any-of completors allowed" | internally two-sided; "single ownership" vs the code's non-exclusive `complete` |
| 16 | Prior ROUTER row (§240): "no ownership to arbitrate — just opens their journal" — `2f8f6aa:84` | L F24 (prior) and `beacon.lua:1-8` (prior) | a prior-vs-prior contradiction the arc surfaced and corrected (A R7) — recorded here because the corrected row is dated inside the arc |

---

## A5. VOCABULARY DRIFT — same thing, new word

| prior term | where | arc term | where |
|---|---|---|---|
| the walk (in-game sprite over run data; addon feature) | M `:117-237` | the walk = `walk.py` desk simulator / W-tests | W0 `:14-26`, X `:1-12` |
| on-ramp | M `:643`, `routes.lua:844-868` | lure | D §1 R-e, §3, §13 |
| complete role / acceptance / satisfier | `routes.lua:564`, `:893` | completor | D §3 `:82`, §4 `:117` |
| beacon (theatre) / anchor | M `:578-596` | theater / scene / arm zone | D §3 `:71-76` |
| child | M `:598-617` | satellite · child · entity | D §4, §13 |
| detect: `shape · reach · reach.up · reach.down · unseen` | M `:609`; `radius/bandUp/bandDown` `routes.lua:688-694` | trigger `{xyz, R, ±H}` / `up down` | D §5 `:133`, §13 `:348` |
| `ifUnseen` (repeat guard, default on) | `routes.lua:631-651`; M `:1000` | `mode: once` / spent-set / latch | D §4 `:99-100`, §1 R-c |
| `goTo` + `supertrack` action (custody chain) | `routes.lua:509-532`, `:764-788` | `pointer <id>` → `activate <childID>` / listen edges | D §13 `:357`, `:370-392` |
| supertracker / tracker / arrow | M, L, R | pointer (also "arrow", "the pointing organ") | D §9-§10, A H0-b |
| detector | M `:141-148`, `:1443-1461` | "There are no 'detectors'" → pre-configured positions / triggers | D §0 `:13-14` |
| flight list / step (anchor·comparison·predicate·effect) | M `:1015-1053` | instruction set / entity table + instructions / `flat` | D §11 `:278-283`, §12, §13 |
| set:stage (escapement / resync) | M `:965`, `:984-993` | hard resync / authoritative SET / boss-set | D §2 `:47-49`, W0 `:21`, W5.3 |
| far-stage policy | M `:995-999`, S `:104-109` | K forward listen / false advance | D §2, W5.2 |
| run (captured) / capture | M `:104-113` | dataset · fixture · legs · surface read | D §12, W0 `:9`, X |
| promotion (spawn from a run) | M `:689-709` | seed / spawn / re-seat | D §12 `:308-314` |
| curation / promotion (editor) | M `:653-709` | EDITOR tier / compile / flatten | D §11 `:227-231` |
| tier (`TierYards`) | `COA_Landmarks/store.lua:44-55` | R / R_close | A A1, D §9 |
| arrival | `beacon.lua:167`; L law 12 | accept / acceptance / hit | A H16 `:756`, X W5, W7.3 |
| arm (a run) | M `:524-529`; `capture.lua:391` | arm zone / armed stage / arm CLEU | D §2-§3, §11 |
| route remote (seventh surface) | S `:72-95` | route remote (kept) · G3 | A §K `:832` |
| consumer (M) / driver (M, S) | M `:1264-1269`, S `:11` | CONSUMER addon 2 / reader / dumb walker | D §11, §12 |
| stage state registers (set / ratchet / maxSeen) | M `:961-967` | ratchet + spent-set + K window | D §2, §4 |

---

_Not determinable from files: whether the "RULED (Battlewrath, 2026-08-17)" lines in A/D were made with the corresponding M sections in view; whether `walk.py`'s rule matches M's reach/`unseen`/stage semantics (not read for this audit); which of M §258 and D §2/§11 was written first within 2026-08-17._
