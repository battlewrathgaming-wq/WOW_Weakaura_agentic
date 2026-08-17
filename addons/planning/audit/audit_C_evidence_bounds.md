# AUDIT C — EVIDENCE and BOUNDS (independent auditor, 2026-08-17)

_Auditor had no conversation context. Worked only from files in the repository and by running the
named tools from the repository root with `py`. Working tree at HEAD `e073820` (§290) plus two
UNCOMMITTED files: `driver_analysis_asklist.md` (+143/−14 — §H16, §K, §I edits) and
`driver_design_advisory.md` (+29 — the §13 "ONLY LURES / ACTIVATE" ruling). Everything below that
cites H16, K, or advisory §13 is citing working-tree text, not a commit. Branch is 22 commits ahead
of `origin/main`._

_Reported as data. No recommendations. Every tool output quoted is from a run in this audit._

---

## C0. Tool runs performed (verbatim tails)

| command | exit | key output |
|---|---|---|
| `py addons/tools/walk.py check` | 0 | `PASS - every W2/W3/W4 golden reproduced.` Fixture `20260817_025542__test1-16__legs.jsonl`, `sha a0cef0e12237`. W2 mean 3.36e-06 · median 2.49e-06 · p99 1.27e-05 · max 1.89e-05 · sd 0.0349..264.4309 · od_is_3d_euclid_within 1.14e-13 · cross_floor_rows 1467 · dz −69.9216..5.2244 · diverge_flags_eps1 0. W3 samples 1738 · moving 1470 · p10 6.96 · p50 7.00 · p90 7.58 · p99 8.44 · max 9.02. W4 1.0s 349 kept 0.01/0.75/1.61/2.41 · 2.0s 175 0.19/2.37/4.15/5.01 · 4.0s 88 1.31/6.32/9.58/11.43 |
| `py addons/tools/walk.py w1` | 0 | Summary lines: W1.6 PASS · W1.7 PASS · W1.9 PASS · W1.2/W1.3 PASS · W1.10 PASS · W1.4 PASS · W1.5 PASS · W1.8 PASS · **`W1 PASS - all eight criteria.`** (eight lines cover ten criteria). W1.6 empirical 4.950714 vs closed 4.950758, diff 4.34e-05, segment 0 of 501 misses. W1.5 violations 0, largest advantage +4. W1.10 real-data: RFC_run1 holes 14 · RFC_Run2 13 · RFC_Run3 12 at gap bound 2.01 |
| `py addons/tools/walk.py w5` | 0 | `W5 emitted. W5.4 PASS.` W5.1 tables (SFK_live 20/21 at R=2 point, 21 segment; SFK_Run4 54/58, 57/58; rfc_combat 24/26 at R=2). W5.2 K=all/K=3 tables identical to result doc plus rfc_combat rows. W5.3 SFK_live R=5 K=3 stage 21/21 {'hit':19,'skip':2}; boss-set {'hit':7,'skip':13,'boss-set':1}. W5.4 SFK_live 21/21 hit 7 skip 14; SFK_Run4 58/58 hit 14 skip 44; rfc_combat 26/26 hit 22 skip 4. W5.5 same-map pairs only. Two-rates 0.2 s 12/18/18/18 vs 1 Hz 13/16/16/18. Cut-corner kill fixture: 0.2 s SILENT / 1 Hz DETECTED — PASS |
| `py addons/tools/walk.py w32` | 0 | (i) jitter ALL n 2239 p50 0.0000 p99 0.0253 max 0.1886 · (ii) `jump apex - MEASURED §284` true apex [1.6404, 1.7368], zspeed 8.0 → 1.6588 · (iii) drop ALL n 1893 p99 2.8900 max 11.3307 · (iv) 16 authored beacons, smallest genuinely stacked separation 9.71 yd. Footer: `admit jitter 0.1886 (measured) reject a 9.71 yd stack (measured)` · `BAND = 2.5 yd, both directions, ERRING TIGHT. Not ruled here`. ⚠ Same output also prints `the band must ADMIT jitter 0.1886 and a jump (UNMEASURED)` |
| `py addons/tools/read_tracker_state.py threshold` | 0 | 9 runs, `8742 rows across 9 run(s)` · `THRESHOLD T in (5.4603, 5.5172] width 0.0568 yd` · `rule sd <= 5.4887 <=> ts == 4 contradicting rows: 0` |
| `py addons/tools/read_tracker_state.py runs --run rfc_combat` | 0 | rows 1933 · ts 2:1874 4:59 · sd 0.80..417.83 · od 0.80..417.83 · `|sd-od| max 3.74e-05` |
| `py addons/tools/verify_calibration.py` | 0 | `CROSS-RUN: 114 case(s), worst error 0.000220 yards`; map 33 floors 1–7 and map 389 floors 0–1 |
| `py addons/tools/emit_worldmap_census.py --help` (⚠ the script has no `--help`; it EMITTED — `git diff addons/maps/worldmap` empty afterwards, no change) | 0 | `transform verified against 1462 captured point(s) from 4 run(s): worst error 0.000000 <- LOOKUP CONFIRMED` |
| `py addons/tools/read_satnav_probe.py addons/landing/records/20260812_113949_493__satnav.json` | 0 | 86 samples · mapID 1 n=29 · mapID 389 n=57 states=['Invalid'] tracking=['True'] gp=[1] sd 0.00..0.00 · vs 3D mean err 0.000000 worst 0.000001 |
| `py addons/tools/read_satnav_probe.py` on 111102 / 112152 / 125020 | 0 | 945 rows vs 3D mean 0.000010 worst 0.000155 · 727 rows mean 0.000054 worst 0.000404 · 99 rows all Invalid, distance nil, gp −1 |
| `py addons/tools/check_interface.py` | 0 | `interface: 6 surface(s) reconcile` · `98 of 98 declared controls registered` |
| `py addons/tools/read_satnav_probe.py --help` | 1 | `FileNotFoundError: [Errno 2] No such file or directory: '--help'` (no help handler; argv[1] taken as a path) |

**Corpus provenance headers inspected (line 1 of every one of the 24 files in `addons/landing/corpus/`).** All carry `_provenance.sha256`, `_provenance.raw_clone`, `_provenance.source`, `_provenanceCovers`. sha256 recomputed against the raw clone on disk for five: test1 `a0cef0e1…` ✔ · rfc_combat `f9092b22…` ✔ · satnav 113949 `644ca0ce…` ✔ · SFK_live `a0cef0e1…` ✔ (same flush as test1) · SFK_Run4 `d0e04ce4…` ✔. Chain record `records/20260817_170747_470__chain.json` sha `93cf4a82…` ✔ against `raw/…chain.lua`. ⚠ `addons/landing/raw/` is gitignored (`.gitignore:64`); only `raw/20260817_025542__test1-16__dungeonrun.lua` is force-tracked, so from a fresh clone the sha in every other header can be READ but not RE-HASHED.

---

## C1. CLAIM LEDGER

Evidence type ∈ {runnable-tool, corpus-file, in-client observation, chat ruling, assertion-only}. Reproduce ∈ {YES, PARTIAL, NO, NOT-RUNNABLE}. "brief" = driver_analysis_brief.md · "ask" = driver_analysis_asklist.md · "acc" = driver_walk_acceptance.md · "res" = driver_walk_result.md · "post" = driver_posture.md · "adv" = driver_design_advisory.md.

| # | claim (short) | where claimed | evidence type | reproduced? | note |
|---|---|---|---|---|---|
| 1 | Lookup transform worst error 0.000000 across 1,462 points, 4 runs, 2 dungeons | brief §2; ask C1, R5; post §11 | runnable-tool (`emit_worldmap_census.py`) | YES | prints `1462 captured point(s) from 4 run(s): worst error 0.000000` |
| 2 | Runtime FIT per-map per-floor, 0.000203 yd worst | brief §2; ask C1; `calibrate.lua:50` | runnable-tool (`verify_calibration.py`) | PARTIAL | tool now prints cross-run worst **0.000220** (corpus grew to 9 runs); 0.000203 not reproduced as stated |
| 3 | Engine distance is 3D yards, mean error 1e-5 over 1,758 samples | brief §2; ask C2 | runnable-tool (`read_satnav_probe.py`) + corpus | PARTIAL | 945+727+86 = 1,758 rows; per-run 3D mean err 0.000010 / 0.000054 / 0.000000; pooled "1e-5" is order-of-magnitude, Barrens run alone is 5.4e-5 (worst 4.0e-4) |
| 4 | `C_Timer.After` frame-driven, identical to OnUpdate accumulator | brief §2 | assertion in brief ("measured, both clocks") | NOT-RUNNABLE | no tool named; records `20260816_16*__timers.json` exist, no reader checked in this arc |
| 5 | Capture 1 Hz, every point carries `t` and `gt` | brief §2; ask D1 | corpus-file | YES | `fields` header lists t, gt on every run-corpus file |
| 6 | Throttler formula / constants (POLL_MIN 0.20, POLL_MAX 2.0, MAX_CLOSING_SPEED 30, ARRIVAL_HOLD 1.0) in `COA_Landmarks/beacon.lua` | ask A1, A2 | code file | NOT-RUNNABLE (not re-read line-by-line here) | cited by line; not a measurement |
| 7 | 7.1 / 3.6 / 1.7 samples through a 5 yd detector at 7 / 14 / 30 yd/s | ask A4, R2; brief §4.1 | arithmetic | YES | 10/(7·0.2)=7.14; 10/2.8=3.57; 10/6=1.67 |
| 8 | Closed-form point-test miss fraction 1.0 % / 4.0 % / 20.0 % at R=5 | ask H0-a; adv §6 | arithmetic | YES | 1−√(1−(s/2R)²): s=1.4→0.99 %; 2.8→4.0 %; 6.0→20 % |
| 9 | Segment test ~30 ops 1 div 0 sqrt; point ~9 ops | ask H4; res W1.1 | assertion / code inspection | NOT-RUNNABLE | walk.py comment claims op sequence mirrors H4; op count not machine-checked |
| 10 | 57 in-dungeon satnav rows: ts=0, sd=0, tr=true, gp=1, sustained | ask F-i, R4; acc W2.2 | runnable-tool (`read_satnav_probe.py`) + corpus | YES | mapID 389 n=57 states Invalid, tracking True, gp 1, sd 0.00..0.00 |
| 11 | test1: 1,739 rows, pin inside SFK floor 6, 7 floors, 0.2 s on all 1,738 intervals | ask H8 | corpus-file | YES | 1,738 intervals min 0.195 max 0.234; floors {1..7} |
| 12 | W2 goldens (1564/175/0; mean 3.4e-6, p99 1.3e-5, max 1.9e-5; sd 0.03..264.43; od 3D Euclid to 1e-13; 2D off 29 yd; cross-floor 1467, dz −69.9..+5.2) | acc W2; res W2; ask H8, H10 | runnable-tool | YES | `walk.py check` PASS |
| 13 | W2.2 divergence at ε=1: 0 rows on test1 | acc W2.2; res | runnable-tool | YES | `diverge_flags_eps1 0` |
| 14 | W2.2b: satnav 57 rows reduced, sd 0, od 4733.0..4736.8, 57/57 flagged | res W2.2b; ask J3/H10 | corpus-file (no CLI mode) | YES (own script) | mapID 389 rows 57, sd0 57, od 4733.038..4736.836, flagged 57, od absent 0 |
| 15 | J3: declined capture 1,386/1,386 flag at ε=1 (test2, ts=0, sd=0, pin not in this space) | ask H12, §I; K | corpus-file (no CLI mode) | YES (own script) | test2 rows 1386, sd==0 1386, ts==0 1386, flagged 1386; pin mapID 33, run mapID 389 |
| 16 | W3 speed goldens p50 7.00 etc. | acc W3; res; ask H8 | runnable-tool | YES | check PASS |
| 17 | W4 goldens (2.41 / 5.01 / 11.43 max) | acc W4; res; ask H8 | runnable-tool | YES | check PASS |
| 18 | W1.6 closed form 4.950758 vs empirical 4.950714, diff 4.34e-05, 0/501 segment misses | res W1.6; ask H12; post §1 | runnable-tool | YES | `walk.py w1` |
| 19 | W1.7 band veto 5 cases PASS | res; ask H12 | runnable-tool | YES | |
| 20 | W1.2/W1.3 seven synthetic cases PASS; "mapID CONSTANT within every one of the 12 landed runs, so no fixture can reach the straddle guard" | res W1.2/W1.3; post §12; walk.py text | runnable-tool + corpus | PARTIAL | synthetic cases PASS. ⚠ The "12 landed runs" count only reaches 12 by including the 4 satnav corpus files (8 run-corpus + 4 satnav at §271; 9,667 = 7,810 + 1,857 rows confirms). `20260812_113949_493__satnav__legs.jsonl` has mapIDs {1, 389} with a transition at row 28→29 and x/y/z on every row — a landed corpus file that DOES straddle |
| 21 | W1.4 no hold PASS | res; ask | runnable-tool | YES | |
| 22 | W1.5 monotonicity 0 violations; +1/+4 at R=2, 0 by R=5 (SFK) | res; ask H12; post §4 | runnable-tool | YES | |
| 23 | W1.8 while semantics 4 PASS | res | runnable-tool | YES | |
| 24 | W1.9 clamp branch PASS (7 rows + 101-phase sweep) | res "at §285"; ask H16 | runnable-tool | YES | |
| 25 | W1.10 gap bound PASS; RFC trio holes 14/13/12 | res; acc W1.10; ask H16 | runnable-tool | YES | |
| 26 | W1 "PASS, all ten" | res "at §285"; ask H16, §I | runnable-tool | PARTIAL | tool prints eight summary lines and `all eight criteria`; ten criteria are covered (H16 calls it cosmetic) |
| 27 | W5.1 transit fraction tables (SFK 20/21, 54/58, 57/58 at small R) | res W5.1; ask H14 | runnable-tool | YES | plus rfc_combat 24/26 at R=2 |
| 28 | W5.2 K=all vs K=3 tables | res W5.2 | runnable-tool | YES | identical numbers |
| 29 | W5.3 SFK_live R=5 K=3 stage 21/21 hit 19 skip 2 | res; post §6 | runnable-tool | YES | |
| 30 | W5.4 self-replay PASS (21/21, 58/58, 26/26) | res; ask H14 | runnable-tool | YES | |
| 31 | W5.5 cross-fixture 58/14/44 · 58/16/42 · 21/18/3 · 21/10/11 | res; post §7 | runnable-tool | YES | |
| 32 | Two-rates on test1: 0.2 s 12/18/18/18 vs 1 Hz 13/16/16/18 | res; post §5; ask H14 | runnable-tool | YES | |
| 33 | Cut-corner kill fixture: silent at 0.2 s, detected at 1 Hz | res "at §285"; ask H16 (A-4 reproduced) | runnable-tool | YES | |
| 34 | A-3(ii) marker = PLAYER position (`Store.AddMarker(runId, Store.Point(), …)`); no kill markers, kinds start/end/pin | walk.py w5 text; acc W5.4 conditional | code inspection | NOT-RUNNABLE | stated in tool output; not re-read in capture.lua here |
| 35 | Posture §3 RFC segment advantage persists past R=5 (RFC_run1 +5 at R=5, +10 at R=2) | post §3 (bench only) — RETRACTED res "What did NOT reproduce" | runnable (via import) | NO | re-ran `walk.w1_5` on the RFC trio under current code: RFC_run1 R=2 +1, R=5 0; RFC_Run2 R=2 +4, R=5 +1; RFC_Run3 all 0. Consistent with the retraction (gap bound now breaks the holes) |
| 36 | rfc_combat: gaps 24 % of run, 92.7 s of 393.8 s, 9 windows 1.2–13.6 s | res "rfc_combat" headline; ask H14 | corpus-file, no tool | PARTIAL | duration 393.8 ✔, 9 windows ✔ (my definition); my window total 52.5 s / lengths 0.8–13.3 — a different window definition; 92.7 not reproduced |
| 37 | rfc_combat: MAX_CLOSING_SPEED exceeded, peak 50.59, 14 samples, all inside pulls | res; ask H14 | corpus-file, no tool | YES (own script) | max 50.59, n>30 = 14; 13 of 14 carry `combat` on the sample row |
| 38 | rfc_combat: `while` radii Taragaman r50 5.0/r99 9.2/rMAX 17.4 dz 1.2; Jergosh 14.8/29.3/29.4 dz 0.9 | res; ask H14 | corpus-file, no tool | NOT-RUNNABLE | no checked-in reader; the numbers were withdrawn as criteria in ask H15 but stand in res text |
| 39 | rfc_combat: lure/destination split 6/6 (net/path 0.73/0.87/0.79 vs baseline 0.68) | res; ask H14 | corpus-file, no tool | NOT-RUNNABLE | withdrawn as criterion structure in H15; stands in res text |
| 40 | W4 doubled by combat: 4.95 max, 2.22 inside gaps | res; ask H14; K ("2.4 gap / 4.95 pull") | corpus-file, no tool | NOT-RUNNABLE | |
| 41 | rfc_combat `|sd−od|` max, sd 415 → 36 | res | runnable-tool | PARTIAL | tool prints sd range 0.80..417.83, |sd−od| max 3.74e-05 (K says "own xyz == engine to 1e-5"; this run is 3.7e-5) |
| 42 | W3.2 jitter 0.1886 max, drop max 11.33, 9.71 yd stack | walk.py w32; res; ask H16 | runnable-tool | YES | |
| 43 | Jump apex four flat jumps 1.6289/1.6359/1.6387/1.6404; true apex [1.6404, 1.7368]; zspeed 8.0 → 1.6588 | res "Measured since"; walk.py w32 (ii); commit d423a68 | corpus-file (`records/20260817_161115_222__unitstate.json`), no reader | PARTIAL (own script) | IsFalling-edge runs at speed 0: 1.6404, 1.6289, 1.6359, 1.6387 ✔. Upper bound / zspeed inference not re-derived |
| 44 | Mounted top speed 17.50 yd/s; mounted jump 1.5726 | res "Measured since" | corpus-file (`…160927_345__unitstate.json`) | PARTIAL | speed field 17.5 present ✔; my apex over the mounted airborne run gives 2.7473 (base = previous z; terrain not controlled) — 1.5726 not reproduced |
| 45 | Character height ankles→hips 0.9645; z datum = base point (−0.11 / −1.08) | res "Measured since"; K | in-client observation (water method) | NOT-RUNNABLE | marks {} in the landed unitstate records; the values live in the commit message / result text |
| 46 | `UnitPosition` DOES NOT EXIST here (declared nil) | res "Measured since" | corpus-file | YES | `payload.declared.UnitPosition == "nil"` in both unitstate records |
| 47 | 5.5 yd comparator: ts==4 ⟺ sd ≤ 5.5, no hysteresis/latency; bracket 5.4595–5.5172, 4,952 rows, 2 pins (H11) / (5.4603, 5.5172], 6,809 rows, 8 runs (post §8) | ask H11; post §8 | runnable-tool | PARTIAL | tool now: (5.4603, 5.5172], **8,742 rows, 9 runs**, 0 contradictions. Bracket matches post; row/run counts differ from both docs (corpus grew) |
| 48 | Client acts on none of it (pin survived 4 round trips, ts back to 2) | post §9 | in-client observation + corpus (test2/3/4) | NOT-RUNNABLE | |
| 49 | W6: 6 set / 6 clear / 6 arrive / 0 skip / 955 rows / finished; worst |sd−od| 1.99e-05; ts=0 at every clear; set follows clear same tick; arrivals 4.02–4.75 | acc W6; res W6; ask H16, K | corpus-file (`records/20260817_170747_470__chain.json`, tracked at e073820) | YES (own script) | summary {sets 6, clears 6, arrives 6, skips 0, rows 955, worstAbsSdOd 1.986e-05}; recomputed worst 1.986e-05; every clear ts=0; each set shares gt with the preceding clear; arrive od 4.0169/4.1260/4.0737/4.3063/4.2975/4.7491 |
| 50 | Detection = own positions; tracker = calibration + arrow (R-a); height never invented (R-b); ±2.5 band stands; only lures / activate; /reload = user recovery; clear is an authored condition | ask H0-b box, H16 C-1; adv §1, §13; res §285/§286 | chat ruling | NOT-RUNNABLE | attributed to Battlewrath by date; no transcript in repo |
| 51 | H6: 9 runs, 5,295 legs, zero ghost legs (§254) | ask H6 bench note | corpus (raw records) | NOT-RUNNABLE | `ghost` not carried in corpus view; not re-checked |
| 52 | 389 → 1,462 stale count in three files | ask R5 | code/doc grep | YES | `emit_worldmap_census.py:16` "WAS 389 until §242"; README 1,462; calibrate.lua:14 1,462 |
| 53 | check_interface exits 0 (J6) | ask §I | runnable-tool | YES | exit 0 |
| 54 | Branch 22 commits unpushed | ask §I | git | YES | `ahead 22` |
| 55 | mapID constant + 0 non-finite of 9,667 rows | post §12 | corpus-file | PARTIAL | current corpus: 12 run-corpus files 9,743 rows, 0 nil/non-finite x/y/z; +4 satnav 1,857 rows = 11,600. 9,667 was the count at dbb63e7 (11 run + 4 satnav files = 8 dungeon runs + satnav... see #20). One satnav file is not mapID-constant |
| 56 | Landmarks `Beacon.Clear()` release-on-arrival ships; AC-19 never reclaim; F24 position outranks quest | acc W6; ask F-ii, R7 | code file / prior ledger | NOT-RUNNABLE | cited to beacon.lua / satnav_ledger F24; not re-read here |
| 57 | Boss engagement = event `INSTANCE_ENCOUNTER_ENGAGE_UNIT` + token poll `boss1..boss5` (capture.lua:667, :239) | ask H10 §261; adv §11 | code file | NOT-RUNNABLE | line-cited; not re-read |
| 58 | Corpus provenance: sha256 of the whole flush; `_provenanceCovers` stated | ask H8; res | corpus-file | YES | 5 hashes recomputed and match |

**Counts:** YES 34 · PARTIAL 10 · NO 1 · NOT-RUNNABLE 13 (58 rows).

---

## C2. Claims with NO verifiable evidence in files (assertion-only or chat-only)

- brief §2 "`C_Timer.After` is frame-driven and identical to an OnUpdate accumulator — measured, both clocks, same second" — no tool or reader in the arc; timers records exist unread (#4).
- All Battlewrath rulings cited by date only (R-a..R-e; ±2.5; "only lures"; "activate"; /reload = user recovery; "the pin only cares about being set"; "stairs are transit"; H1 bench note "a dungeon is one instance") — chat-only (#50).
- rfc_combat `while` radii per boss, lure/destination split, "gaps 24 % / 92.7 s", W4 4.95/2.22 split — no tool emits them; only res text and commit 4dec11c message (#36, #38–#40).
- Character height 0.9645 / z datum water marks — in-client observation, `marks {}` in the landed records (#45).
- Mounted jump 1.5726 (#44).
- Posture §9 "the client acts on none of it" — observation (#48).
- H6 "9 runs, 5,295 legs, zero ghost" (#51).
- Op-count claims (~9 / ~30 + 1 div) — assertion in tool comment and H4 (#9).
- A-3(ii) "marker is the player's position" — asserted in tool text from code reading (#34).
- Posture §3 table — bench-only and now NOT reproducible under current code (#35; retracted).

---

## C3. BOUNDS CHECK (brief §5) and STOPS (brief §6)

**§5.1 NEVER produce anything that tells the user what a good route IS**
- CROSSES-then-withdrawn: res "rfc_combat" — *"So R must cover the excursion, not the median — `r99` would have given Taragaman 10 yd and dropped the fight"* (a beacon-sizing recommendation); *"So an authored route carries at least two kinds of beacon… a route built from combat markers has only one kind in it"*; ask H14 "`while` radii: R covers the excursion (rMAX), not r99". Withdrawn as criteria in ask H15 ("Each dressed a corpus observation as a criterion") and fenced in walk.py, but the res text stands unedited.
- APPROACHES (emit-only, labelled): adv §10 zig-zag readout ("pointer targets per 100 yd of route, heading change between consecutive pointers … never a warning"); adv §2 off-route readout ("distance to the route polyline … a number, never a reroute"); ask H14 "combat footprint … a readout the author reads, never a rule" (H15 moved it to author-side readouts); ask H7 "safe R … whether it becomes a floor is Battlewrath's"; res W3.2 "too TIGHT the beacon does not fire. The author SEES it and adjusts."
- COMPLIES: W5.2 "Emit both — no recommendation"; W5.5 "numbers only, no grade"; walk.py fence "generating or scoring routes … OUT OF SCOPE".

**§5.2 Ours = what the player KNOWS; not gameplay input**
- none found. Every action in adv §5/§13 is pointer / note / cleu-arm / complete; W6 probe sets and clears the supertracker only.

**§5.3 We never learn dungeons (no shipped per-dungeon table, no DBC dependency, no authored map data)**
- APPROACHES: `addons/COA_DevDump/route_chain.lua` (tracked; in `COA_DevDump.toc:30`) is a GENERATED per-dungeon route (Ragefire Chasm, six coordinates, sha of source) shipped inside a dev-probe addon for W6. Not in `COA_DungeonRun`; header says "Re-emit rather than edit."
- APPROACHES-then-withdrawn: rfc_combat per-boss `while` extents (Taragaman/Jergosh) and combat-gap model — ask H15: "a model of combat, which is dungeon knowledge (§17)"; res text stands.
- PRE-EXISTING BASIS, not arc content: the LOOKUP reads client DBC boxes at emit (brief §2 states it as basis); `calibrate.lua` per-map cache is session-only ("nowhere persistent, deliberately", ask C1).
- COMPLIES: adv §11 "A NAME is available; a GROUPING is not — the author's knowledge, never ours"; ask H14 "whether a place is a pull is dungeon knowledge — unauthorable"; W5.3 boss-set uses names/timestamps FROM the record.

**§5.4 ABSENT, NOT WRONG**
- COMPLIES: walk.py W1.10 `gap_bound: None` "ABSENT, not passing"; res W2.2b `absentFields` and the recorded `r.get('od', 0)` slip; ask H7 "'no data' for an unrun map (never a default)"; adv §12 "needs a surface read — ABSENT NOT WRONG".
- APPROACHES: acc W3.2 specifies "the shipped default = a value that admits the p99 jump and rejects the smallest floor separation" and w32 prints `BAND = 2.5 yd … Not ruled here — stated so the readout carries the same number the driver does` — a default constant carried by the readout (ruled by Battlewrath per res §285/§286, so a ruling, not a silent default). adv §3 "arm zones default OPEN band … satisfaction triggers default TIGHT band" — defaults by kind.

**§5.5 Emit, don't interpret**
- CROSSES-then-withdrawn: res "rfc_combat" — *"That is the driver's entire operating envelope and nothing in W5 models it. A route walked against the whole record grades the driver on 76 % of a run where it has no work to do"*; the 6/6 split "with a mechanism rather than a distance". H15 withdrew; text stands.
- APPROACHES (labelled): post §5 "MECHANISM MY READING, UNPROVEN"; res two-rates "offered as a candidate mechanism and not as a finding"; walk.py W5.3 "arguably CORRECT … Which reading wins is not the bench's to pick".

**§6 ✖ re-deriving units or the fraction→world fit** — none found in arc-authored tools. `verify_calibration.py` (pre-existing) still runs and prints a fit; W2 `od_is_3d_euclid_within` re-checks the RECORD's `od`, not the fit. res "z datum corroborated as the BASE POINT" / character height are unit-of-z measurements the walk.py fence itself names as drift ("deriving physics constants for their own sake").

**§6 ✖ designing a distance function from scratch** — APPROACHES with escalation: ask H0-b proposes detection on own-position Euclid distance and names the stop itself ("This touches the brief's 'never compute your own' line and the stop-list's 'no distance function from scratch'"); ruled R-a. H4's point-to-segment test is new geometry on own positions, sanctioned under R-a. res W2.2b: `od` "does not need the distance to be MEANINGFUL, only COMPUTABLE" — own distance across coordinate spaces, used as a divergence signal only.

**§6 ✖ any route optimiser, scorer or ranker** — APPROACHES: adv §10 zig-zag metric; adv §2 off-route distance; res rfc_combat net/path scoring of the six pins (0.73/0.87/0.79/0.58/0.27/0.40 vs 0.68 baseline) — a per-pin score, withdrawn in H15 as criterion, text stands. W5.2/W5.5 emit counts with "no recommendation / no grade".

**§6 ✖ anything assuming threads, sleep, yield, or a tick you control** — none found. grep of the five arc docs for coroutine/thread/sleep/yield returns only the word "thread" as "chat thread". adv §11 chunks Douglas-Peucker/walk across frames; ask H5 heartbeat is event-driven with a POLL_MAX rate-limit on the frame throttler.

**§6 ✖ anything needing per-dungeon authored data** — APPROACHES: `COA_DevDump/route_chain.lua` (above); W3.2 (iv) reads 16 authored Height_map beacons from staging `dungeonroutes` captures (a corpus input, not shipped). None in the product driver path.

**§6 ✖ deciding the reach SHAPE is open** — none found. ask H0-b argues the (d3D, band) combination ("a lens, not a cylinder"), which brief §4.2 leaves open; ±2.5 stands per res §285/§286.

**Bounds findings total: 3 crossed-then-withdrawn (all in the res "rfc_combat" section, text still standing), 9 approaches, 0 uncorrected crossings in the tool path (walk.py fence at line 248 states the withdrawals).**

---

## C4. Arc numbers vs tool output run here (exact values both sides)

| doc value | where | tool value | tool |
|---|---|---|---|
| FIT 0.000203 yd worst | brief §2; ask C1; calibrate.lua:50 | 0.000220 yd (114 cross-run cases) | verify_calibration.py |
| 5.5 threshold: 4,952 rows, 2 pins, bracket 5.4595–5.5172 | ask H11 | 8,742 rows, 9 runs, (5.4603, 5.5172] | read_tracker_state.py threshold |
| 5.5 threshold: 6,809 rows, 8 runs | post §8 | 8,742 rows, 9 runs | same |
| 3D distance "mean error 1e-5 over 1,758 samples" | brief §2; ask C2 | 945 rows mean 0.000010; 727 rows mean 0.000054 (worst 0.000404); 29 rows 0.000000 | read_satnav_probe.py |
| "own xyz == engine to 1e-5" | ask K | rfc_combat |sd−od| max 3.74e-05; test1 1.89e-05; chain 1.99e-05 | read_tracker_state / walk / record |
| rfc_combat "`sd` 415 → 36" | res rfc_combat | sd 0.80 .. 417.83 | read_tracker_state runs |
| "W1 PASS, all ten" | res, ask H16, §I | `W1 PASS - all eight criteria.` (10 covered) | walk.py w1 |
| "0 of 9,667 rows" non-finite; "12 landed runs" mapID-constant | post §12; res W1.2/W1.3; walk.py w1 text | 12 run-corpus files = 9,743 rows (0 nil/non-finite); +4 satnav = 11,600; satnav 113949 has mapIDs {1, 389} | own script over corpus |
| Posture §3 RFC advantage R=5: +5 / +3 / 0 | post §3 (retracted) | +0 / +1 / 0 under current code | walk.w1_5 via import |
| rfc_combat gaps "92.7 s of 393.8 s, 9 windows 1.2–13.6 s" | res | 393.8 s ✔; 9 windows ✔; 52.5 s, 0.8–13.3 s under the auditor's window definition | own script |
| W5 (acc): "each beacon's FIRST-PROXIMITY time emitted beside it"; W5.3 "stage timeline emitted per run (stage, gt, cause)" | acc W5, W5.3 | w5 prints aggregate (iii) marker→sample p50/p90/max and cause COUNTS; no per-beacon first-proximity time and no timeline rows are emitted (timeline is built internally, `walk.py:1045`, and summarised) | walk.py w5 |
| W3.2 (acc): "Emit p50/p99/max for each" of (i)(ii)(iii) | acc W3.2 | (i) and (iii) have p50/p99/max; (ii) jump is one line (bracket only) | walk.py w32 |

---

## C5. Tool / record hygiene

1. `walk.py w1` summary says `all eight criteria` while listing/proving ten (W1.9, W1.10 present) — acknowledged as cosmetic in ask H16 and §I; still printed.
2. `walk.py w5` W5.1 header: `the tight band is a CANDIDATE … W3.2 rules none because the jump term is unmeasured`, and `walk.py w32` (iv) footer: `the band must ADMIT jitter 0.1886 and a jump (UNMEASURED)` — while `walk.py w32` (ii) prints `jump apex - MEASURED §284` with a bracket. Same tool, contradictory labels.
3. `walk.py` W1.2/W1.3 text: "mapID is CONSTANT within every one of the 12 landed runs" — the corpus directory holds a satnav-corpus file with two mapIDs and x/y/z on every row (`20260812_113949_493__satnav__legs.jsonl`, transition at row 28→29). Either the count 12 excludes satnav (then the count is 9, not 12) or the constancy claim is false for one file. `walk.load()` globs `*__legs.jsonl` and would load it under `--run 113949`.
4. `read_satnav_probe.py --help` → `FileNotFoundError` (argv[1] treated as a path). `emit_worldmap_census.py --help` → performs a full emit (idempotent here; no diff).
5. Provenance sha256 in every corpus header points at `addons/landing/raw/*.lua`, which is gitignored (`.gitignore:64`); only test1's raw is force-tracked. On a fresh clone 23 of 24 headers cannot be re-hashed. The `records/20260817_170747_470__chain.json` W6 record is tracked; its raw clone is not.
6. `driver_analysis_asklist.md` (H16, K, §I updates) and `driver_design_advisory.md` (§13 "ONLY LURES … ACTIVATE") are UNCOMMITTED in the working tree; the acceptance state and gap analysis they carry exist only locally at audit time.
7. `driver_walk_result.md` §"rfc_combat" retains the combat-model text (gaps envelope, `while` radii sizing, 6/6 split, "R must cover the excursion") that ask H15 withdrew and walk.py's fence lists as OUT OF SCOPE; the res section "What did NOT reproduce" retracts only posture §3. The commit message 4dec11c is the only other place those numbers exist.
8. `driver_walk_result.md` "WHERE THE TESTING IS UP TO — at §285" table says `W6 NOT STARTED` while the same file's later section says `W6 — DONE`; the earlier table is stale relative to the file's own end.
9. `driver_walk_acceptance.md` W6 keeps both "What was left, before it was done" and the DONE block; W6.1 appears as both PASS and "near-certain, ten seconds to confirm" in the same section.
10. `read_tracker_state.py threshold` labels the four satnav runs `satnav ?` for zone (absentFields carry no zone) — the H11/posture "2 of OUR pins" / "8 runs" counts are not recoverable from the current tool output, which pools 9.
11. `walk.py check --run <other>` returns exit 2 with "comparison skipped" (documented in code, not in the result doc's "Run it yourself" block).
12. `emit_worldmap_census.py` verifies against "4 run(s)" (1,462 points) while the corpus now holds 9 dungeon runs; the LOOKUP proof is not extended to the newer captures by that tool (verify_calibration.py covers the FIT side across all 9).
13. No mode of `walk.py` emits the W5.3 timeline rows or per-beacon first-hit indices/gt to a file, which W7.1 names as the byte-equal golden ("Byte-equal on the emitted timeline").
14. Files referenced and present: `records/20260812_113949_493__satnav.json` ✔; `records/20260817_170747_470__chain.json` ✔; `addons/COA_DevDump/route_chain.lua` ✔; `addons/tools/emit_chain_route.py` ✔; `addons/tools/verify_calibration.py` ✔; `maps/worldmap/README.md` ✔; `addons/planning/satnav_ledger.md` (cited F20–F39) — not opened in this audit. Files referenced and absent: none found. Staging `Height_map` / `Height_map_with_cross_walk` dungeonroutes captures are present under gitignored `addons/landing/staging/`.
