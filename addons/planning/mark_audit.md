# Mark audit — comments in the addon sources

**Auditor:** independent pass, 2026-08-15. **Proposal only — no source file was modified.**

Premise taken as given, then tested: the existing `★`/`★★`/`★★★`/`⚠` marks are noise until proven
otherwise. A mark was treated as evidence of nothing; every comment block was judged on its own
content.

> **Headline.** The marks are not merely uncalibrated — they are **anti-correlated with value**.
> All 307 marked lines in scope sit in two addons. The other seven addons carry **zero marks
> between them** and hold roughly **160 rulings and 75 facts**, including the bench's flagship
> ruling and its most reusable client facts.

---

## 1. Coverage

### Read in full

| Area | Files | Lines | Marked lines | Blocks examined |
|---|---:|---:|---:|---:|
| `addons/COA_DungeonRun/` | 11 | 5,788 | 239 | ~330 |
| `addons/COA_DevDump/` | 18 | 3,057 | 61 | ~190 |
| `addons/COA_GuardianPlates/` (excl. `Libs/`) | 4 | 5,016 | **0** | 190 |
| `addons/COA_Landmarks/` | 7 | 1,655 | 7 | ~130 |
| `addons/MancerLedger/` | 3 | 1,584 | **0** | ~50 |
| `addons/COA_PetGrid/` | 3 | 817 | **0** | ~25 |
| `addons/COA_StatePlates_*/Options.lua` | 3 | ~100 | **0** | ~7 |
| **Total** | **49** | **~18,000** | **307** | **~925** |

**~6,165 comment lines examined across ~925 distinct comment blocks.**

### Verdict tally

| Verdict | Approx. count |
|---|---:|
| RULING | **~205** |
| FACT — UNIVERSAL | **~125** |
| FACT — BENCH | **~35** |
| MECHANICAL | ~245 |
| NARRATIVE | ~90 |

The narrative share is lower than the brief predicted — but that is a statement about the
*comments*, not the *marks*. The marks are overwhelmingly attached to the narrative and mechanical
material; the rulings and facts are overwhelmingly unmarked.

### Mark distribution *within audit scope*

| Tier | Count | Share |
|---|---:|---:|
| `★★★` | 8 | 2.6% |
| `★★` (not `★★★`) | 57 | 18.6% |
| `★` (single) | 212 | 69.1% |
| `⚠` | 30 | 9.8% |
| `⚠⚠` | **0** | **0%** |

The rest of the repo-wide 538 sits in `addons/tools/smoke/` (`smoke_dungeonrunmap.lua` alone carries
98) — **out of scope, not audited.**

### Not done — stated honestly

- `addons/tools/smoke/*` — excluded by the brief; ~230 further marks unexamined.
- `addons/COA_GuardianPlates/Libs/`, `addons/refs_*`, `addons/landing/` — excluded.
- `addons/Materials/`, `addons/Mob_Autogroup/` — not named in the brief, not read.
- **I did not verify the `§`, `DR-`, `AC-`, `F` and `M` citations resolve** to their planning
  documents. Much of the reasoning is load-bearing on documents taken on trust. A real gap.
- **I did not re-measure any client fact against a live client.** They are recorded as the author's
  measurements; many cite a probe record id or client source file:line and are credible on that
  basis. Contradictions between them are flagged in §6.
- Verified by reading code: the `DR-20` single-owner claim, the zero-persistent-`OnUpdate` claim,
  one stale comment block, one resolved contradiction, and one latent inconsistency.
- **Facts hiding in string literals** (UI option tooltips) were outside scope but are real, e.g.
  `COA_StatePlates_Aggro/Options.lua:36` — native threat borders show only while grouped.

---

## 2. RULING candidates

Settled decisions with reasoning that constrain future work. **~205 found; the strongest listed.**

### The constitutional layer

| file:line | Headline | Why it qualifies |
|---|---|---|
| `COA_GuardianPlates/Core.lua:476` | **Don't engrain custom internal clocks when the game can do the waiting** | Battlewrath's, explicitly generalising. **Unmarked**, inside a changelog paragraph, in a file with zero marks across 2,880 lines. Quoted back at `task_api.lua:468` as the ruling a false claim contradicted — proof it is load-bearing. |
| `COA_Landmarks/store.lua:21` | **The eight standing data laws** (one account SV with an owner field · immutable opaque id · schemaVersion · records are data only · no index · hard delete · session state unpersisted · tags as typed) | The constitution every other module is written against. **Unmarked.** |
| `COA_Landmarks/core.lua:15` | **If code and the design brief disagree, the brief is right and the code is the bug** | Sets the authority order for every future change. Unmarked. |
| `COA_DungeonRun/capture.lua:29` | **Capture is the ONLY spawn — everything downstream inherits, nothing derives** | The addon's governing law. Unmarked. |
| `COA_DungeonRun/capture.lua:30` | **We hold WHAT HAPPENED, never what the world is or what it meant** | Scope boundary that has repeatedly decided what not to build. Unmarked. |
| `COA_DungeonRun/capture.lua:8-26` | **DR-1: edges from the events, state from the API — never infer state from the event that woke you** | Cross-addon (restates Landmarks AC-24), and *verified against the installed WeakAuras fork* with file:line citations. Unmarked. |
| `COA_DungeonRun/store.lua:3` / `COA_Landmarks/store.lua:3` | **Exactly one module touches the saved-variables global** | A rewrite replaces one file, not a repo search. **Verified: it holds.** Both unmarked. |
| `COA_DungeonRun/store.lua:111-117` | **DR-4: both clocks on every point — `time()` joins, `GetTime()` measures** | Wall-clock is the only join to the client's own combat log and is unrecoverable afterwards. Unmarked. |
| `COA_DungeonRun/store.lua:29-34` | **DR-6/DR-9: record every combat, write as captured, never clean/merge/dedupe** | Makes every later curation feature a *view*. Unmarked. |
| `COA_DungeonRun/map.lua:8-16` | **§17: the addon never learns dungeons — no shipped table, no DBC, no per-dungeon anything** | The most constraining law in the addon. `★` only. |
| `COA_Landmarks/store.lua:63`, `:76` | **Read what we know, REFUSE what we do not, never guess; unversioned data cannot be our data** | Refuses the patching-on-patches path outright. Unmarked. |
| `COA_DevDump/core.lua:3`, `:15`, `:20` | **A task runner, not a bag of dump commands; one envelope per run; chat is by-exception** | Module and output boundaries every task file must obey. Unmarked. |
| `COA_MancerLedger/core.lua:24` | **Read-only on the driver DB; fold only KNOWN fields; note unknown ones; shape violations skip the fight and say so once, loudly** | The whole consumer contract in four clauses. Unmarked. |

### Scope and refusal

| file:line | Headline | Why |
|---|---|---|
| `COA_Landmarks/core.lua:6` | **Meaning, exactly-where and which-zone are ours; HOW TO TRAVEL is not** | Keeps the addon out of routing territory permanently. Unmarked. |
| `COA_Landmarks/minimap.lua:6` | **The minimap is a CONTROL surface, never a display surface — no pins, no blips** | Blocks any future minimap-pin request. Unmarked. |
| `COA_Landmarks/pins.lua:56` | **The note is PULLED on hover; nothing announces itself on approach** | The core anti-nag law. Unmarked. |
| `COA_Landmarks/beacon.lua:99` / `widget.lua:106` | **Pinning is ALWAYS a user act — nothing re-pins automatically** | Forbids auto-repin forever. Unmarked. |
| `COA_Landmarks/beacon.lua:185` | **If something else takes the supertrack slot we never take it back** | Contention is resolved by one-click repin, never by priority-fighting. Unmarked. |
| `COA_Landmarks/store.lua:224` | **Orphan recovery is STOP FILTERING, not detection — we hold no character roster by design** | Rules out any future roster-tracking "fix". Unmarked. |
| `COA_Landmarks/store.lua:287`, `:325` | **We own NO vocabulary — tag and owner lists are mirrors of what the user already typed** | "We learn who owns something here, not who your characters are — a smaller claim." Unmarked. |
| `COA_Landmarks/editor.lua:54` | **Autocomplete OFFERS and never CORRECTS; nothing is rewritten behind the user** | Unmarked. |
| `COA_Landmarks/editor.lua:216` | **Tags are stored exactly as typed — no trim, no case-fold, no merge** | Any cleanup pass is forbidden by construction. Unmarked. |
| `COA_GuardianPlates/Core.lua:330` | **No spec→role inference table will be built** | CoA classes are custom: ours to maintain forever with no upstream. Unmarked. |
| `COA_DungeonRun/routes.lua:374-378` | **No validation on authoring — refusing would be grading the author's work** | Explains several deliberate non-features. `★`. |
| `COA_DungeonRun/driver.lua:92` | **The driver INFORMS, it never grades** | Governs everything not yet built. Unmarked. |
| `MancerLedger/core.lua:155` | **The driver's per-GUID grain is deliberately unfolded — a known field we choose not to consume, not a gap** | Unmarked. |
| `MancerLedger/core.lua:363` | **Observed-in-fight accounting shows "-", never a false zero** | Zero would be a lie. Unmarked. |

### Architecture and discipline

| file:line | Headline | Why |
|---|---|---|
| `COA_GuardianPlates/Core.lua:16` | **Core is the ONLY code that may call `SetAlpha`/`SetStatusBarColor`/the glow lib** | Modules compute intent, Core draws. Unmarked. |
| `COA_StatePlates_Friendly/Options.lua:3` + `Aggro/Options.lua:3,25` | **Core is INERT until attach; loading a sub-addon IS the declaration of interest; disabling returns the core to baseline** | The whole plugin architecture, with no uninstall step. Unmarked. |
| `COA_GuardianPlates/Core.lua:1864` | **Modules restore first, Core wipes shared tables second** | Reversed order leaves state stuck on a pooled frame handed to a new unit. Unmarked. |
| `COA_GuardianPlates/Core.lua:1322`, `:1388` | **Win native fights with persistent instance-scoped post-hooks and a re-entrancy guard — never `hooksecurefunc` a name copied from another addon without live confirmation** | Unmarked. |
| `COA_GuardianPlates/Core.lua:1682` | **Diagnostic hooks must log unconditionally, outside the match branch** | Otherwise "never fired" and "fires on the wrong object" are indistinguishable silence. Unmarked. |
| `COA_GuardianPlates/Core.lua:1730` | **Prefer a texture we create and own over any frame owned by the native driver** | Unmarked. |
| `COA_GuardianPlates/FriendlyPlates.lua:399` | **Turning a feature off collapses to baseline immediately, never leaves residue to expire** | "Turning something off shouldn't lead to more work because it was on." Unmarked. |
| `COA_GuardianPlates/FriendlyPlates.lua:421` | **Action handlers no-op until attach — but the restore path stays UNgated** | Restore must always be safe to run. Unmarked. |
| `COA_Landmarks/beacon.lua:114` / `MancerLedger/minimap.lua:56` / `COA_DungeonRun/editor.lua:403` | **An `OnUpdate` exists only while its gesture is in flight — idle cost exactly zero** | Stated independently in three addons. **All unmarked except the DungeonRun one (`★`).** |
| `COA_Landmarks/beacon.lua:219` | **The interval check must sit BEFORE the API call it throttles** | The original read player position 59×/sec and threw it away; "a census can see a throttle exists, not where it sits." Unmarked. |
| `COA_PetGrid/core.lua:212` / `feed_live.lua:320` / `MancerLedger/ui.lua:4` | **Layout runs only when the row/column SET changes; ticks write contents and never re-anchor** | "The data is complex, the UI should be calm." Unmarked. |
| `COA_DungeonRun/map.lua:385-392` | **A guard whose failure case the fixtures cannot REACH is untested, not safe** | Credited with catching four bugs. `★` only. |
| `COA_DevDump/task_callwitness.lua:14` / `task_cleu.lua:57` | **The instrument must not manufacture — or add — the effect it measures** | Permanently limits instrumentation shape. Unmarked. |
| `COA_DevDump/task_dump.lua:23`, `:103` | **Serialiser: no silent caps, nothing dropped, non-string keys tagged; a compile failure lands NOTHING** | "A landed syntax error would look like evidence about the game." Unmarked. |
| `COA_DungeonRun/core.lua:125` / `COA_Landmarks/core.lua:27` / `pins.lua:41` | **No silent anything — a refusal complains loudly** | Stated three times across two addons. Unmarked. |
| `MancerLedger/core.lua:216`, `:249` | **Drift detection must count TABLES as well as numbers; shape breakage LATCHES a lockout with no partial trust** | A missed table field went invisible once. Unmarked. |
| `COA_DevDump/task_api.lua:18-30` | **The probe is READ-ONLY on the client — PULL only, never PUSH** | `★★★` — **earns it**. |
| `COA_DevDump/task_api.lua:39-55` | **Every experiment carries a control; a dead apparatus must be loud about being dead** | Paid for by run 1 producing three false findings in red. `★★★` — **earns it; arguably the best note in the repo.** |
| `COA_DevDump/task_api.lua:464-469` | **A name search proving ABSENCE proves nothing** | `⚠` only — **under-marked**. |
| `COA_DungeonRun/calibrate.lua:18` | **The fraction→world fit is a constant of the MAP, not of a run** | `★★` — earns it. |
| `COA_DungeonRun/object.lua:7` | **All edit options of an object live in its own pane; the promoter mints and hands off** | `★★` — earns it. |
| `COA_DungeonRun/editor.lua:209` | **Use the client's own widgets — custom code locks users out** | `★`. |
| `COA_DungeonRun/map.lua:1648` | **Default OFF for wheel-zoom and right-drag** | "An addon that takes either on install has taken something nobody offered." `★`. |

---

## 3. FACT candidates

`UNIVERSAL` = a property of the client or of Lua, true for anyone writing against it (WeakAura
authors, macro authors) — **promote cross-bench.** `BENCH` = specific to this bench's data or
design. **~160 found; the strongest listed.**

### UNIVERSAL — promote these

| file:line | Headline | Why |
|---|---|---|
| `COA_Landmarks/editor.lua:33` → carried to `COA_DungeonRun/widget.lua:8` | **`InputBoxTemplate`'s middle texture anchors to `$parentLeft`/`$parentRight` BY NAME — a nameless EditBox draws only two 8px end caps** | Recorded twice, in two addons, labelled "cost a live bug to find". **Neither copy carries a mark**; the DungeonRun file spends its `★★` on button placement instead. |
| `COA_Landmarks/store.lua:139` → carried to `COA_DungeonRun/store.lua:75` | **`GetPlayerMapPosition` returns 0,0 when the world map displays a DIFFERENT zone (pfQuest guards identically); `SetMapToCurrentZone` fixes it, but only safely while the map is hidden** | "The single most common map-coord bug", plus the condition under which the fix is legal. Both copies unmarked. |
| `COA_Landmarks/store.lua:144` | **The mapID from `GetCurrentPlayerPosition` is the CONTINENT, not the zone the world map draws** | Continent/zone indices must be recorded alongside any fraction. Unmarked. |
| `COA_Landmarks/pins.lua:131`, `:138` | **A stored map fraction is valid only against the continent+zone index pair it was taken on; pin placement is CENTER→`WorldMapButton` TOPLEFT at `(fracX*w, -(fracY*h))`** | Matching on mapID alone scatters every pin across the continent. Unmarked. |
| `COA_DungeonRun/store.lua:82-86` | **`GetCurrentMapDungeonLevel()` reports the floor the WORLD MAP IS SHOWING, not the player's** | Agrees only after `SetMapToCurrentZone`. Unmarked. |
| `COA_DungeonRun/capture.lua:113-115` | **`UnitExists` returns `1`, not `true` — never compare against `true`** | The archetypal 3.3.5-ism. Unmarked. |
| `COA_DungeonRun/capture.lua:335-338` | **`PLAYER_DEAD` is the only moment the death recap is readable — `CurrentRecap` rolls on `PLAYER_UNGHOST` and `PLAYER_ENTERING_WORLD`** | Unmarked. |
| `COA_DungeonRun/capture.lua:78-83` | **The death recap folds `SPELL_HEAL` — `attacker` means "caster of this event", not "an enemy"** | Without a filter, "who killed me" names your healer. `★` only. |
| `COA_DungeonRun/capture.lua:428` | **`PLAYER_ENTERING_WORLD` also fires on login and on every `/reload`** | Unmarked. |
| `MancerLedger/core.lua:522` | **SavedVariables globals do not exist while a file body executes — the DB is nil until `ADDON_LOADED`** | UI modules must reach data through an accessor, never capture it at load. Unmarked. |
| `COA_PetGrid/core.lua:81` | **At `ADDON_LOADED` a frame has no rect yet — `GetLeft()` returns nil** | Any anchor migration must defer to the first laid-out frame. Unmarked. |
| `COA_PetGrid/core.lua:63` | **`GetLeft`/`GetTop` return values in the FRAME's scale space, not UIParent's** | Otherwise saved positions drift every time the user rescales. Unmarked. |
| `COA_PetGrid/core.lua:341` | **nil-valued defaults are invisible to `pairs()`, so a "copy defaults" loop can never reset a key back to nil** | Unmarked. |
| `COA_PetGrid/feed_live.lua:4-7` | **The 3.3.5 CLEU vararg layout: 1 ts, 2 sub, 3-5 src, 6-8 dst, 9+ suffix; SWING crit=15, SPELL amount=12/crit=18, SWING_MISSED missType=9, SPELL_MISSED missType=12** | The canonical offsets; there is no `CombatLogGetCurrentEventInfo` on this client. **Unmarked — and it is what settles the contradiction in §6.** |
| `COA_Landmarks/beacon.lua:104` + `COA_DevDump/task_satnav.lua:118` | **Calling `C_SuperTrack.SetSuperTrackedPosition` directly skips the priority ladder — it appears to work, then is silently overwritten; `SuperTrackerUtil` is the correct entry** | Recorded independently in two addons; explicitly corrects an earlier finding. Both unmarked. |
| `COA_Landmarks/beacon.lua:13`, `:18` | **Across a map boundary supertracking returns state Invalid with distance **0.00**, not nil, while `IsSuperTrackingAnything()` still reports true; a loading screen produces a momentary Invalid** | Zero satisfies every radius test — any distance-only "am I there yet" check fires the instant you zone. Unmarked. |
| `COA_Landmarks/beacon.lua:172` | **`GetSuperTrackedPosition`'s distance is engine-computed 3D yards (mean error 1e-5 over 1,758 samples); `NavigationState.InRadius` is the engine's own radius and is unsettable** | Never compute your own distance. Unmarked. |
| `COA_Landmarks/beacon.lua:28`, `:166` | **1500/727 are `SuperTracker.lua` Lua-side conventions, not engine limits (engine returned InRange at 3,742 yd); `NavigationState.Invalid == 0`** | Anyone treating them as caps clips their own range for nothing. Unmarked. |
| `COA_Landmarks/beacon.lua:244` | **`SelectQuestLogEntry` also fires on `QUEST_TURNED_IN`, because `UpdateSelectedQuest` calls it unconditionally** | Anything hooked there gets an extra unrelated invocation. Unmarked. |
| `COA_Landmarks/editor.lua:51` | **`AutoComplete_Update`/`GetAutoCompleteResults` is a C API that only ever returns PLAYER NAMES** | The stock inline-completion mechanism cannot be reused for any other vocabulary. Unmarked. |
| `COA_Landmarks/editor.lua:223` | **EditBox `OnTextChanged` fires on deletion too — completing on a shrink makes backspace un-deletable** | Unmarked. |
| `COA_Landmarks/pins.lua:27` | **`AtlasInfo[name] = {texture, w, h, left, right, top, bottom, flipH, flipV}`; `SetAtlas` additionally forces native size and fails silently under `pcall`** | Texture + `SetTexCoord` read straight off `AtlasInfo` is the deterministic path. Unmarked. |
| `COA_Landmarks/pins.lua:150` | **`WORLD_MAP_UPDATE` fires whenever the displayed map changes** | The correct rebuild trigger; no timer needed. Unmarked. |
| `COA_Landmarks/widget.lua:97` | **`SetMapByID` is not guaranteed present on this client** | Must be `pcall`'d. Unmarked. |
| `COA_DungeonRun/map.lua:1167` + `COA_DevDump/task_api.lua:310` | **"`SetTexture` resets `TexCoord`" is FALSE for the raw texture API — the reset lives in a stock Lua wrapper** | Measured; corrects a belief the offline harness had generalised to every texture. `⚠`/`★` — badly under-marked. |
| `COA_DungeonRun/map.lua:37`, `:990`, `:1055` | **`WorldMapDetailFrame` is 1002×668 (coordinate space); tile art is 4×3×256 = 1024×768 (padding the stock map clips)** | Confusing them stretches placement +2.2% horizontally, +15% vertically. `★`. |
| `COA_DungeonRun/map.lua:981` | **`mapY` runs DOWNWARD — fraction 0 is the top edge** | Unmarked. |
| `COA_DungeonRun/map.lua:423-426` | **`GetCurrentMapAreaID()` is off by one from the internal mapID AND indexes a different id space** | Two independent ways to be wrong. The clearest of three statements, and unmarked. |
| `COA_DungeonRun/map.lua:1031` | **A terrain map shifts the dungeon level by one — the client itself does `dungeonLevel - 1`** | Quoted from `WorldMapFrame.lua:463`. `★★` — earns it. |
| `COA_DungeonRun/map.lua:200` | **3.3.5 has no `SetClipsChildren` — the ScrollFrame-with-scroll-child pattern is the client's own** | `★`. |
| `COA_DungeonRun/calibrate.lua:69` | **The client's map axes are swapped and negated versus world axes, and the convention differs by map** | Forces a full 6-parameter affine fit. `★`. |
| `COA_DungeonRun/object.lua:257` | **`OnTextChanged` passes `userInput` as arg #2 — TRUE when typed, FALSE for programmatic `SetText`** | `★★★` — **earns it.** |
| `COA_DungeonRun/object.lua:268` + `task_api.lua:148` | **`OnTextChanged` is DEFERRED, COALESCED and CHANGE-ONLY** | A same-value `SetText` fires nothing; the feared freeze loop was never possible. `⚠`/`★`. |
| `COA_DungeonRun/editor.lua:381` | **`RegisterForDrag` has a movement threshold — a small precise nudge never starts a drag** | Buried inside a `★★` bug story. |
| `COA_Landmarks/beacon.lua:65` + `capture.lua:45,52` + `map.lua:260,385` | **A `local function` referenced before its declaration resolves to a nil global — and `SetScript("OnUpdate", nil)` is legal, so the handler silently never runs; dropping `local` leaks into `_G`** | Recorded **five times across two addons** because it shipped live twice. |
| `COA_DevDump/task_api.lua:460` | **`C_Timer` exists and works on this fork but has NO enumerable members — `pairs()` sees nothing** | Therefore a name search cannot prove absence. `★★★` — earns it. Independently confirmed at `Core.lua:481`. |
| `COA_DevDump/task_dump.lua:109` | **`{ pcall(f) }` + `#` is a trap — a nil in the returns makes a sequence with holes; `select("#", ...)` is the only honest count** | Bit on live use: eight values asked, two recorded. Unmarked. |
| `COA_DevDump/task_dump.lua:62`, `:86` | **`_G` is full of cycles (an unguarded walk hangs the client); but siblings legitimately share tables — only the PATH is a cycle** | Unmarked. |
| `COA_DevDump/payload_macros.lua:84`, `:138` | **Under `pcall`, return values shift by one — `UnitClass`'s TOKEN is the THIRD value** | Hit twice in one session. Unmarked. |
| `COA_DevDump/payload_macros.lua:28` | **An unsupported macro conditional and a currently-false one are BOTH falsey — only the `[x]`/`[nox]` pair separates them** | The core method for probing conditional support on any client. Unmarked. |
| `COA_DevDump/payload_macros.lua:57`, `:126` | **`cursor` was never a unit token (a macro-layer special case); `MAX_CHARACTER_MACROS`=36 globally but a LOCAL 18 shadows it in `QuickKeybindActionPicker`** | The latter names a likely real client bug. Unmarked. |
| `COA_DevDump/task_spec.lua:3`, `:10` | **Spec NAMES are player-authored WTF labels, not class facts; and `GetSpecializationInfo` is NOT a pure getter — it migrates AND CLEARS saved state** | A "read" that mutates. Unmarked, and expensive to rediscover. |
| `COA_DevDump/task_plates.lua:4` | **Native plates are `WorldFrame` children and smooth-stacking stretches `WorldFrame` 8×, so UIParent-coordinate hit-testing misses them** | Cited to client source lines. Unmarked. |
| `COA_DevDump/task_perf.lua:13` | **`GetAddOnCPUUsage` returns 0 unless `scriptProfile` is 1 AND the client has reloaded** | Unmarked. |
| `COA_DevDump/task_cleu.lua:110`, `:231` | **`collectgarbage("count")` is heap IN USE, not total allocated (first record read −13,248kb); the retained combat-log buffer read 0 in combat WITH logging on** | Unmarked; the strongest facts in a file whose stars sit on field labels. |
| `COA_DevDump/task_callwitness.lua:19`, `:203`, `:233` | **Capturing a wrapped function's returns costs a table per call in Lua 5.1; a nil serialises away in SavedVariables; addon Lua cannot read files from disk** | Unmarked. |
| `COA_DevDump/task_tooltip.lua:11` | **`SetSpellByID` may be absent — `SetHyperlink("spell:<id>")` is the 3.3.5-native equivalent** | Unmarked. |
| `COA_GuardianPlates/Core.lua:122` | **The same creature is announced under two unit tokens at once (`nameplateN` and `target`), same GUID, same plate Frame** | Unguarded, every consumer double-processes one plate. Unmarked. |
| `COA_GuardianPlates/Core.lua:175` | **`GetNamePlateForUnit` fails at `NAME_PLATE_UNIT_REMOVED` time — 20/20 in live capture** | The cached-plate fallback is the norm, not an edge case. Unmarked. |
| `COA_GuardianPlates/Core.lua:313`, `:371`, `:460` | **`UnitGroupRolesAssigned` returns a real role only for LFD-formed groups; `GetNumPartyMembers()` returns an empty roster while genuinely grouped; roster events fire before group data is populated (~2s)** | Three separate roster traps, one observed as an empty roster for ~13 minutes. Unmarked. |
| `COA_GuardianPlates/Core.lua:1163`, `:659` | **`CompactUnitFrame` drives native plate visuals from `self.optionTable`, assigned BY REFERENCE to a shared global default and re-run on every reassignment; `healthBarColorOverride` is its first-priority branch** | Native recycling IS the cleanup, and the enemy's re-assert becomes your enforcement. Unmarked. |
| `COA_GuardianPlates/Core.lua:1143` | **The native aggro frame is NOT reachable as `healthBar.aggroHighlight` — use `_G[healthBarName.."aggroHighlight"]`** | A 100% deterministic failure went undetected because indexing a never-set field returns nil silently. Unmarked. |
| `COA_GuardianPlates/Core.lua:1330`, `:1473` | **`hooksecurefunc` hooks can never be uninstalled; hooking an instance method catches calls regardless of whether the caller is global, local or renamed** | The one hook technique immune to name guessing. Unmarked. |
| `COA_GuardianPlates/Core.lua:1628` | **`debug.getupvalue` can see closure-captured tables invisible to any `_G` scan — but this client's addon sandbox blocks it** | Closes off an entire avenue. Unmarked. |
| `COA_GuardianPlates/Core.lua:936` | **`PixelGlow_Start`'s auto dash-length formula goes negative at N≥20; a negative length silently draws nothing, no error** | An invisible, un-loggable render-failure class. Unmarked. |
| `COA_GuardianPlates/Core.lua:2483`, `:2491` | **WotLK's default chat frame has no text selection/copy at all; `"BackdropTemplate"` is a Retail 8.0+ requirement — on 3.3.5 `SetBackdrop` works on any plain Frame** | Two traps for anyone porting retail snippets. Unmarked. |
| `COA_GuardianPlates/EnemyPlates.lua:607`, `:976` | **The `cond and X or Y` idiom breaks whenever X is itself falsy — confirmed live** | Banned in this codebase in favour of plain `if/elseif`. Unmarked. |
| `COA_GuardianPlates/EnemyPlates.lua:1078` | **`pcall`'s first return is "did it error", not the callee's boolean — `local ok = pcall(f)` counts every call as success** | Caused a test to report every unit as touched. Unmarked. |
| `COA_GuardianPlates/EnemyPlates.lua:349`, `:513` | **`UnitDetailedThreatSituation`'s `rawPercentage` can exceed 100 and STOPS updating once you are primary target; and it returns nil across the board when you have no entry — `x and true or false` collapses that to false** | Two distinct traps in one API. Unmarked. |
| `COA_GuardianPlates/EnemyPlates.lua:181` | **CoA's classes are entirely custom — no Warrior/Paladin/Druid/DK, so `UnitClass`-based role detection never matches** | Any ported class logic is silently dead here. Unmarked. |
| `COA_GuardianPlates/FriendlyPlates.lua:51`, `:62`, `:111`, `:493` | **Ascension backports the nameplate unit-token API to 3.3.5; there is no `nameplateShowFriendlyPlayers` CVar; plates are pooled and reused; the driver recalculates plate alpha EVERY rendered frame** | Kills the era-standard "nameplates have no unit token" assumption. Unmarked. |
| `COA_GuardianPlates/FriendlyPlates.lua:625` | **`InterfaceOptionsFrame_OpenToCategory` must be called twice (Blizzard first-open quirk)** | Unmarked. |
| `COA_GuardianPlates/AggroPlates.lua:9-22` | **Native `UpdateHealthBorder`/`UpdateAggroHighlight` form a complete tank-threat system gated on `optionTable` fields, whose colours must be Color-like objects answering `:GetRGBA()`, and whose meaning flips by role** | Plain `{r,g,b}` tables will not work. Four dense facts. Unmarked. |

### BENCH (selected)

| file:line | Headline |
|---|---|
| `COA_DungeonRun/store.lua:88-97` | 42 of 43 multi-floor dungeons stack floors over the same footprint, so floor cannot be recovered from world x/y; `DungeonMapChunk.dbc` has the z bounds but is keyed by `WMOGroupID`, which no Lua call exposes. |
| `COA_DungeonRun/map.lua:577` | **Floor index is not route order** — SFK_Run4 ran 1→2→1→7→3→4→5→6. `★★`, earns it. |
| `COA_DungeonRun/map.lua:1485` | Dungeon maps run 0.1–2.8 yd/px (typically 0.2–0.7) — the reason no snapping was built. |
| `COA_DungeonRun/driver.lua:91` | A walkway 9.71 yd above its floor sits only 3.12 yd away planar. Unmarked. |
| `COA_PetGrid/feed_live.lua:8`, `:9`, `:13` | Necro minions carry TYPE_PET `0x1000` (not GUARDIAN) + MINE; `UNIT_DIED` is SILENT for overwrite-despawn (0 of 71, with sample bias named); minion buffs are one aura instance per individual. |
| `COA_PetGrid/feed_live.lua:42` | Banshee / Skeletal Mage / Gargoyle buff ids are a **NAMED GAP** — never summoned in the record. A declared hole, not an oversight. |
| `MancerLedger/core.lua:3`, `:13`, `:41`, `:103` | The full driver contract: a 10-deep ring newest-first, deduped by a fingerprint that must be recomputed with the driver's own recipe; the driver commits ~1.5s after `PLAYER_REGEN_ENABLED`. |
| `MancerLedger/core.lua:339` | The driver accrues unit-time only from in-fight summon windows — live-caught at 174.9 hits/min on a lone warrior. |
| `COA_GuardianPlates/Core.lua:1979`, `:2102` | ~0.03ms/unit reclassify, 40-unit raid ≈1ms/tick, worst case 5–6ms (threshold set at 15ms); `Ascension_NamePlates` is the active driver, TurboPlates disabled. |
| `COA_DungeonRun/core.lua:29-38` | Three floored maps carry `defaultDungeonFloor = -1`. **Explicitly labelled an inference pending live confirmation — NOT a settled fact.** See §6. |

---

## 4. Marks that should be DEMOTED

**No `⚠⚠` marks exist in scope at all** — the tier is entirely unused, which is itself evidence the
scale was never calibrated.

### The one that must go first

| file:line | What it is | Why it doesn't earn the weight |
|---|---|---|
| `COA_DungeonRun/capture.lua:379-394` (`★★` + `★`) | **STALE AND SELF-REFUTED** | It asserts (a) "Map.ArtFor's identity guard catches the mismatch and refuses" and (b) "M8 earns its keep here… comparing that to where we stand is the check." **Both are false, and the file says so 200 lines earlier at `capture.lua:182` (`⚠`).** Verified in code: `map.lua:457` returns `run.mapFile` **unconditionally** — the identity check only governs the in-zone fallback; and `captureMapArt` (`capture.lua:194-202`) never calls `GetCurrentMapAreaID`, it gates on `WorldMapFrame:IsShown()`. The `★★` is mis-indented to column 0 while every neighbour is indented — a fossil left by the rewrite. **A `★★` currently sits on the most misleading comment in the addon.** |

### `★★★` that does not earn the top tier

| file:line | What it is | Why |
|---|---|---|
| `task_api.lua:159` | "v4: what kind of deferral is it?" | **An open question at time of writing** — the block says "the harness models NONE of this yet." Later answered at `:148`. A lab-notebook entry. |
| `task_api.lua:241` | "His race question — staleness/freshness" | Also a question, phrased conditionally. Unsettled by its own text. |
| `task_api.lua:540` | "The catch-all, and it is the whole lesson of run 1" | Describes a summary function; the lesson is stated better at `:39` (`★★★`). Duplicate weight. |
| `task_api.lua:65` | "v5: invisibility by alpha, not by position" | Half version history, half a real universal fact. **Split it:** keep the fact, demote the changelog. |

**Four of the eight `★★★` in scope are questions, duplicates, or changelogs.**

### Design narrative and taste wearing `★★`

| file:line | What it is | Why |
|---|---|---|
| `map.lua:65` | Colour/shape channel choice | Display taste. |
| `map.lua:105` | Promoted objects "speak a different language" | Restated near-verbatim at `map.lua:930` — **both carry `★★`.** |
| `map.lua:193` | Zoom exists because half the vocabulary is drawing | Feature justification; the *fact* inside (0.198 vs 2.77 yd/px) is what's worth keeping. |
| `map.lua:212` | "Stages, not increments" | UI preference plus an apology for building the wrong control first. |
| `map.lua:238` | Zoom anchors on view centre | Nice reasoning ("the cursor is also a PEN") — still a UI preference. |
| `map.lua:268`, `:328` | The layer table; which dungeon is authored | Structure explanation. (`:338`, the circularity Battlewrath caught, is closer to a ruling.) |
| `map.lua:946` | "Every art key, so a completeness check is possible" | Mostly the story of §63 forgetting two tables. |
| `map.lua:1289`, `:1303` | Where the stable readout is drawn | Layout. `:1303` is largely "it was in the wrong corner". |
| `map.lua:1406`, `:1419`, `:1451`, `:1493`, `:1525` | Selection / eviction / drag-write behaviour | All five are "here is a bug I shipped and how I fixed it". Good engineering notes; not durable knowledge. |
| `map.lua:1478` | No snapping when dragging | The *fact* (0.1–2.8 yd/px) earns keeping; the rest is commentary. |
| `map.lua:1574` | The map-controls widget layout | An ASCII diagram of a D-pad. Purely mechanical. |
| `map.lua:1795` | The two gesture ticks persist | A settings decision. |
| `map.lua:1913` | "§77 answers §76's open question, and the answer is A TICK" | Version narrative about a checkbox. |
| `map.lua:1980` | Pinned reading, bottom-left, own frame, mouse disabled | Mechanical frame setup. |
| `widget.lua:91` | The pin button is at the top and full width | **Button placement carrying `★★` in a 155-line file whose universal client fact at `:8-11` carries no mark at all.** This single pairing shows the scale inverted. |
| `object.lua:52` | "§79 fills the first behaviour field" | Duplicates `routes.lua:333` (`★★`). |
| `object.lua:242` | "Stage is a field, not a fact" | A correction narrative — a field moving between two lists. |
| `promoter.lua:166` | The button's verb follows the mode | UI mode narrative. |
| `promoter.lua:196` | "No edit surface here" | Restates `object.lua:7` (`★★`) from the other side. |
| `promoter.lua:436` | The stage field is ghosted, not pre-filled | UI preference. |
| `promoter.lua:484` | The running order self-organises by value | Duplicates `routes.lua:176`/`:428`. |
| `promoter.lua:523` | "Register for the selection" | Mechanical wiring plus a bug story. |
| `routes.lua:371` | "Stage is editable after the mint — which is what §56 said all along" | Self-correction narrative. |
| `routes.lua:216` | "Placement — the drag, and why the origin is kept" | The rule is real but stated three times (`routes.lua:216`, `:275` `★`, `map.lua:983` `★★`). Two should drop. |
| `editor.lua:376` | The handles reworked | A bug post-mortem. **Extract the `RegisterForDrag` fact; demote the story.** |
| `editor.lua:535` | The third surface opens from the bottom | Button placement — and the block concedes nothing is enforced. |
| `driver.lua:6` | "Why this exists before the behaviours do" | A process note about build order. |

### `★` marks in `task_cleu.lua` that are labels or restatements

`:129` and `:182` are field labels on assignments. `:199` restates `:25`. `:276` restates `:46`
eleven lines away. `:296` restates the **unmarked** `:132-134` plus run history.
**Five of that file's nine stars are labels or restatements of an unmarked neighbour.**

### Straight duplicates that should not both carry marks

- `map.lua:1383-1387` and `:1468-1472` — **byte-identical `★` blocks**.
- `map.lua:1217` and `:1330` — identical forward-declaration notes.
- `map.lua:260` and `:385` — the same lesson, plus three more copies unmarked elsewhere.
- `map.lua:577` and `editor.lua:518` — the same `★★`.
- `map.lua:105` and `:930` — the same `★★`.
- `capture.lua:277` and `widget.lua:91` — the same `★★` pin argument on two surfaces.

---

## 5. Unmarked comments that matter

**The audit's clearest result.** Everything below carries no `★`.

1. **`COA_GuardianPlates/Core.lua:476` — "don't engrain custom internal clocks when the game can do
   it for us."** Battlewrath's, explicitly generalising. It sits *inside a v3.5.5 changelog
   paragraph*, unmarked, in a file with **zero marks across 2,880 lines** — while `map.lua` spends
   26 `★★` on layout and iconography. `task_api.lua:468` later quotes this ruling back as the thing
   a false claim contradicted, which is proof it is load-bearing.

2. **Seven of nine addons carry no marks and roughly 160 rulings.** `COA_Landmarks` alone holds
   ~55 rulings, including its eight-law constitution at `store.lua:21` and the authority order at
   `core.lua:15` ("if code and the brief disagree, the brief is right and the code is the bug").
   `MancerLedger` holds the full consumer contract at `core.lua:24`. `COA_StatePlates_*/Options.lua`
   states the entire plugin architecture in one sentence at `Aggro/Options.lua:3`. None marked.

3. **The two most-carried facts in the repo are both unmarked, in both of their copies.**
   The `InputBoxTemplate` naming trap (`Landmarks/editor.lua:33` → `DungeonRun/widget.lua:8`) and
   the `GetPlayerMapPosition` 0,0 trap (`Landmarks/store.lua:139` → `DungeonRun/store.lua:75`).
   Both are explicitly labelled as lessons that cost live bugs. The forward-declaration Lua trap is
   recorded **five times** across two addons; only two copies carry any mark.

4. **`COA_GuardianPlates` is the densest universal-fact territory in the repo and has zero marks.**
   `Core.lua:122` (one creature, two tokens), `:175` (`GetNamePlateForUnit` fails at removal —
   20/20 live), `:371` (`GetNumPartyMembers` empty while grouped), `:1163` (`optionTable` shared by
   reference — native recycling IS the cleanup), `:1330` (`hooksecurefunc` can never be
   uninstalled), `:1628` (the sandbox blocks `debug.getupvalue`), `AggroPlates.lua:9-22` (the native
   tank-threat system and its Color-object requirement).

5. **`COA_Landmarks/beacon.lua` is a supertracker manual nobody marked.** `:13` (Invalid returns
   distance **0.00**, not nil — so a distance-only arrival check fires the instant you zone), `:28`
   (1500/727 are Lua conventions, not engine limits — engine answered at 3,742 yd), `:104` (direct
   `SetSuperTrackedPosition` is silently overwritten), `:172` (engine distance is 3D yards, mean
   error 1e-5 over 1,758 samples), `:244` (`SelectQuestLogEntry` fires on `QUEST_TURNED_IN`).

6. **`COA_DevDump`'s hard client facts live in its unmarked files.** `task_spec.lua:10` (a "getter"
   that mutates saved state), `task_satnav.lua:118`, `task_plates.lua:4`, `task_dump.lua:109`,
   `payload_macros.lua:84`, `task_perf.lua:13`. Meanwhile the one marked file in that addon spends
   five of nine stars on field labels.

7. **`COA_PetGrid/feed_live.lua:4-7` carries the canonical CLEU offsets** — and is what resolves the
   contradiction in §6. Unmarked, in a file with no marks at all.

8. **`COA_DungeonRun`'s own constitution is unmarked** while its UI is heavily marked:
   `capture.lua:29-30` and `:8-26`, `store.lua:3` (DR-20, which I verified holds), `store.lua:111`
   (DR-4), `capture.lua:113` (`UnitExists` returns 1), `:335` and `:428`, `map.lua:981` and `:423`.

9. **`COA_PetGrid/feed_live.lua:42` — a NAMED GAP.** Three minion buff ids are declared missing
   because they were never summoned in the record. Naming the hole is exactly what the bench's own
   invariants ask for, and it carries no emphasis of any kind.

10. **The `FACT:`/`RULING:` prefix convention itself.** Ten lines now use it: `capture.lua:29,30` ·
    `calibrate.lua:48` · `driver.lua:91,92` · `map.lua:990` · `object.lua:6` · `routes.lua:48,172` ·
    `GuardianPlates/Core.lua:476`. **Not one carries a star.** The author has already built the
    replacement for the star system without apparently noticing — and it is strictly better:
    greppable, typed, and it forces a one-line headline.

---

## 6. Honest assessment

**The marking system is not salvageable, and should be replaced rather than recalibrated.**

- **The scale is inverted at the extremes.** In `widget.lua`, a note about where a button sits
  carries `★★`; a universal client-template fact that cost a live bug to find carries nothing. That
  is the ranking reversed inside one 155-line file.
- **Coverage is the opposite of value.** All 307 marks sit in two addons. The other seven —
  5,016 lines of GuardianPlates, 1,655 of Landmarks, 1,584 of MancerLedger, 817 of PetGrid — carry
  **zero marks and roughly 160 rulings and 75 facts.** The marks measure which files the author was
  excited about, not which carry knowledge.
- **The top tier is not reserved.** Four of eight `★★★` are open questions, duplicates or
  changelogs — two literally interrogative, one saying in its own text that nothing is modelled yet.
- **The tiers are not distinguishable.** 69% of marks are single-`★`, which makes `★` mean "I am
  writing a comment". `⚠⚠` has **zero** uses. A five-level scale where one level is 69% of use and
  another is unused is a two-level scale with extra ceremony.
- **Marks do not decay when the claim does.** `capture.lua:379-394` carries `★★` on text the same
  file refutes 200 lines earlier and that I confirmed false against the code. Emphasis was applied
  once and never revisited. **This is the bench's own invariant 3 — "a stored field isn't a live
  field" — reappearing as a stored *comment* that isn't a live one.**
- **Marks encourage restatement.** Because a mark feels like a place to make the argument, the same
  rule gets re-argued at every site: new-else-original three times, the forward-declaration lesson
  five times, "no argument = no run" byte-identically twice. The marks multiplied the prose instead
  of indexing it.

**The replacement already exists here — three times over.** `COA_Landmarks` uses `AC-n` numbered
laws. `COA_DungeonRun` uses `DR-n`. `COA_GuardianPlates` uses version-stamped status words and —
crucially — **visibly retires disproven claims** (`Core.lua:1553` "CONFIRMED" → `:1698` "RETIRED",
with the disproof and its sources). All three are unmarked and all three outperform the stars,
because they encode *status and identity*, not volume. The stars are the only convention here that
does not survive contact with a changing fact.

**What I would do.** Keep two typed, greppable prefixes, stated **once** at the authoritative site
and cross-referenced from everywhere else:

```
-- RULING: <one line, settled, whose decision, what it constrains>
-- FACT:   <one line, measured, with the measurement or record id>
```

Add `FACT (UNIVERSAL):` so cross-bench promotion is one `grep`. Everything else — wrong turns,
version history, apologies, layout reasoning — stays as ordinary prose with **no mark**. It is
often good prose and worth keeping; it simply is not an index.

`addons/invariants.md` already exists as the home for transferable laws, and
`grep -rn "FACT (UNIVERSAL):"` would become the promotion list feeding it.

**Against over-correcting.** A minority of heavy marks genuinely earn their weight and should
survive migration: `object.lua:257` (`userInput` arg #2), `task_api.lua:18` and `:39` (read-only
hard line; every experiment carries a control), `task_api.lua:458` (`C_Timer` unenumerable),
`map.lua:1031` (terrain shifts the level by one), `map.lua:577` (floor index is not route order),
`calibrate.lua:18` (map constant, not run constant), `object.lua:7` (edit options live on the
object). The fault is not that the author marked bad things — it is that he also marked everything
else, and left everything outside two addons unmarked.

### Findings that outrank the marking question

1. **`capture.lua:379-394` is stale and self-refuted** (§4). Verified against code. Fix first.
2. **`task_petlog.lua:14` disagrees with its own code** — the prose says the pet mask is the
   `0x1000|0x3000` family; line 28 defines `TYPE_GUARDIAN = 0x2000`. The code is right; the comment
   would propagate a wrong constant if lifted verbatim.
3. **`Core.lua:1553` is disproven at `:1698`**, and `Core.lua:1120` is corrected in place at
   `:1143`. Both read as settled fact unless you read to the end. GuardianPlates at least *marks*
   the retirement — no other file does.
4. **RESOLVED during this audit:** `task_cleu.lua:78` (`select(8)` = destFlags) appeared to
   contradict `task_petlog.lua:52` (which refuses to assume positions past the subevent).
   `COA_PetGrid/feed_live.lua:4-7` gives the canonical layout — 1 ts, 2 sub, 3-5 src, 6-8 dst — so
   `select(8)` is **correct** and petlog's stance is conservative caution, not a conflict. Worth
   noting *the resolution came from an unmarked comment in an unmarked file.*
5. **`Core.lua:2319` ("`debugprofilestop` is genuine, callable anywhere") sits in tension with
   `task_cleu.lua:25` ("it can silently fail to advance")**. Probably compatible — availability
   versus resolution — but reconcile before promoting either.
6. **A latent, undocumented inconsistency:** the two hand-rolled minimap buttons compute ring
   position differently. `COA_Landmarks/minimap.lua:59` divides the cursor by
   `UIParent:GetEffectiveScale()` while comparing against `Minimap:GetCenter()`;
   `MancerLedger/minimap.lua:87` uses `Minimap:GetEffectiveScale()` throughout. The Landmarks
   version mixes scale spaces and is masked whenever the two scales happen to match. **Neither
   carries a comment of any kind** — this one is invisible to any emphasis scheme.

**Six stale, contradictory or latent-bug findings in ~6,000 comment lines is the real result.** No
emphasis scale can fix that, because a star says *loud*, never *true*. Only a convention carrying
status — one that gets retired when the claim dies, as `COA_GuardianPlates` already does — can.

### One scope caution

`COA_DungeonRun/core.lua:29-38` reads as authoritative and is marked `★`, but its own last
paragraph says the correlation "is an inference until someone stands in one and looks." Under the
settled/unsettled test it is **neither a fact nor a ruling** — it is a well-designed open question
and should be tagged as one. That is precisely the failure mode the star system cannot express.
