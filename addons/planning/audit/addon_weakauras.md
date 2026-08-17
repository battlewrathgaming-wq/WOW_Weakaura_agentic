# Audit — WeakAuras as a programmatic / conditional machine (2026-08-17)

_Independent audit, from files only. Target: `F:\games\Ascension_wow\resources\ascension-live\Interface\AddOns\WeakAuras`
(TOC `## Version: 5.21.2`, `## Interface: 30300`, `## X-Flavor: 3.3.5`; `Init.lua:12` `versionString = "5.21.2 Beta"`;
`WeakAuras.lua:4` `local internalVersion = 86`) and `WeakAurasOptions` beside it. Lua 5.1, no threads.
Cites are `File.lua:line` relative to the WeakAuras folder unless prefixed `Options/`. Quotes ≤ one short phrase per cite.
Sections 1–8 as briefed; each ends with REUSABLE MECHANISM / POSTURE NOT TO INHERIT. No other recommendations._

_Method: direct reads of `WeakAuras.lua`, `Conditions.lua`, `AuraEnvironment.lua`, `RegionPrototype.lua`, `BuffTrigger2.lua`,
`Animations.lua`, `DynamicGroup.lua`, `TimeMachine.lua`, `SubscribableObject.lua`, `TSUHelpers.lua`; two sub-audits (GenericTrigger /
CLEU; Transmission / Modernize / Profiling / Init) whose cites I spot-checked against the files. A third sub-audit (DynamicGroup /
BuffTrigger2 / Animations) did not return to this thread — its ground is covered here from my own direct read._

Abbreviations: **WA** = `WeakAuras.lua` · **GT** = `GenericTrigger.lua` · **BT2** = `BuffTrigger2.lua` · **C** = `Conditions.lua` ·
**RP** = `RegionTypes/RegionPrototype.lua` · **DG** = `RegionTypes/DynamicGroup.lua` · **AE** = `AuraEnvironment.lua` ·
**T** = `Transmission.lua` · **M** = `Modernize.lua` · **P** = `Profiling.lua` · **An** = `Animations.lua`.

---

## 1. LOAD / ARM — which auras are active at all

**Compiled load predicate per aura.** On `Add`, WA compiles the aura's `data.load` block into a Lua source string via
`ConstructFunction(load_prototype, data.load)` (WA:786-904; call at WA:3066) — the prototype is `Private.load_prototype`
(`Prototypes.lua:963`), whose args carry `init = "arg"` (becomes a function parameter), `test`, `optional`, and **`events`**
("the events on which the test must be reevaluated", `Prototypes.lua:975`). Each enabled arg's `arg.events` are unioned into an
`events` set returned alongside the source (WA:870-874, :903). Two functions are compiled: the real load func and a
"forOptions" variant that skips `optional` args (WA:3077-3079; `loadFuncs[id]` / `loadFuncsForOptions[id]` WA:3089-3090).

**Event → aura index for re-scan.** `loadEvents[event][id] = true` for every event the aura's load block depends on, plus
`loadEvents["SCAN_ALL"][id]` always (WA:3067-3075; table at WA:291 "Mapping of events to ids"). Groups go under
`loadEvents["GROUP"]` (WA:3025-3026).

**Scan.** `scanForLoadsImpl(toCheck, event, arg1, ...)` (WA:1529-1654): `toCheck = toCheck or loadEvents[event or "SCAN_ALL"]`
(WA:1534) — so an event only touches auras that declared it; early return `if toCheck == nil or next(toCheck) == nil` (WA:1553).
It then gathers **all** world state once (player/realm/zone/subzone/guild/race/faction/zoneId/role/raidRole/class/inCombat/
inEncounter/alive/pvp/vehicle/mounted/raidMemberType/size,difficulty/group/groupSize/ruleset/specialization/manastorm —
WA:1557-1601) and calls every candidate's `loadFunc("ScanForLoads_Auras", inCombat, alive, ...)` with the same 30-arg tuple
(WA:1614-1615). Transitions: `shouldBeLoaded and not loaded[id]` → `toLoad` + `Private.EnsureRegion(id)` (WA:1617-1620 —
regions are created lazily **at load**, not at Add); `loaded[id] and not shouldBeLoaded` → `toUnload` (WA:1626). Tri-state store:
`loaded[id] = true | false ("could be loaded", options view) | nil` (WA:1633-1639). Only if `changed > 0 and not paused` are
`Private.LoadDisplays` / `Private.UnloadDisplays` / `FinishLoadUnload` called (WA:1643-1647), then parents re-evaluated via
`ScanForLoadsGroup` (WA:1649, :1656-1680 — a group is loaded iff any leaf is) and `Private.callbacks:Fire("ScanForLoads")` (WA:1650).
`Private.ScanForLoads` is gated `if not WeakAuras.IsLoginFinished() then return` (WA:1682-1687).

**Which events re-scan.** Fixed frame `loadFrame` (WA:1689-1716) registers 25 events (`PLAYER_TALENT_UPDATE`, `SPELL_UPDATE_USABLE`,
`PLAYER_DIFFICULTY_CHANGED`, `VEHICLE_UPDATE`, `PARTY_MEMBERS_CHANGED`, `RAID_ROSTER_UPDATE`, `PLAYER_LEVEL_UP`,
`PLAYER_REGEN_DISABLED/ENABLED`, `PLAYER_ROLES_ASSIGNED`, `SPELLS_CHANGED`, `ASCENSION_KNOWN_ENTRIES_UPDATED`,
`MYSTIC_ENCHANT_*`, `ASCENSION_CA_SPECIALIZATION_ACTIVE_ID_CHANGED`, `ACTIVE_MANASTORM_UPDATED`, `UNIT_INVENTORY_CHANGED`,
`PLAYER_EQUIPMENT_CHANGED`, `PLAYER_DEAD/ALIVE/UNGHOST`, `PLAYER_FLAGS_CHANGED`, `PARTY_LEADER_CHANGED`, `GUILD_ROSTER_UPDATE`);
`unitLoadFrame` (WA:1718-1724) for `UNIT_FLAGS/ENTERED_VEHICLE/EXITED_VEHICLE/FACTION` filtered `if (arg1 == "player")` (WA:1735);
`zoneEventGuard` for `ZONE_CHANGED*` (WA:1749-1751) with a **map-open workaround**: while `WorldMapFrame:IsShown()` the event is
parked in `eventsFired` and replayed on `WorldMapFrame` `OnHide` (WA:1753-1772; comment WA:1742-1744 "may not always show the
correct zone"). Handlers are only attached in `Private.RegisterLoadEvents()` (WA:1726-1740), which the login coroutine calls
after `AddMany` (WA:1212). GT adds one: `Private.ScanForLoads(nil, "WA_DELAYED_PLAYER_ENTERING_WORLD")` 0.8 s after entering world
(GT:1208-1224 per sub-audit).

**Load / unload fan-out.** `Private.LoadDisplays(toLoad, ...)` (WA:1850-1875): registers global conditions
(`Private.RegisterForGlobalConditions(uid)`, WA:1853), **resets** `triggerState[id].triggers/activationTime/triggerCount/show/
activatedConditions` (WA:1854-1858), then `triggerSystem.LoadDisplays(toLoad, ...)` for each registered trigger system (WA:1864-1866),
then the aura's custom `onLoad` in the sandbox (WA:1867-1874). `Private.UnloadDisplays` (WA:1877-1925) is the mirror: custom `onUnload`
first, then trigger systems, then `wipe(triggerState[id][i])` for every trigger + `show = nil` (WA:1890-1898), cancel autohide timers
(WA:1900-1909), `Private.UnloadConditions(uid)` (WA:1912), collapse region + all clones + cancel animations (WA:1914-1918).
`UnloadAll()` (WA:1774-1821) is the same for everything, plus `Private.UnloadAllConditions()` and `triggerSystem.UnloadAll()`, ending
`wipe(loaded)`.

**Login sequence = a coroutine on a budgeted scheduler.** `Private.Login` (WA:1171-1240) runs as `Private.Threads:Immediate('login',
loginThread, 15000, 1000)` (WA:1239): `Private.Pause()` → migrate history → `AddMany` → `RegisterLoadEvents` → `Private.Resume()`
(which `UnloadAll` + `scanForLoadsImpl()` full scan, WA:1823-1848) → drain `loginQueue` → `loginFinished = true` → dynamic groups'
`RunDelayedActions` (WA:1229-1236). Yields carry cost estimates in µs (`coroutine.yield(8000)`, WA:1202). Scheduler: `threads` at
WA:4245-4363, pools `urgent/normal/background/instant`, per-frame budgets `runThreadPool(urgent, start+15000, 1000)`, `normal +20`,
`background +2` in `debugprofilestop()` units (WA:4348-4353); the OnUpdate frame hides itself at `size == 0` (WA:4300-4302) and
during combat is toggled by `PLAYER_REGEN_*` (WA:4354-4362). Actions/sounds are globally squelched for `db.login_squelch_time`
(default 10 s) after entering world (WA:1262, :1319-1324; `squelch_actions` WA:284).

**Cost model summary (load layer).**
- Per event: one table lookup `loadEvents[event]`; if hit, one full world-state gather + N compiled boolean funcs (N = auras that
  declared the event). Nothing per aura otherwise.
- Per frame: nothing in the load layer.
- Never: unloaded auras have no region (`EnsureRegion` at load), no trigger index entries, no timers, no conditions.
- One-time: login coroutine, budgeted.

**REUSABLE MECHANISM**
- Compile the arm-predicate to a Lua function once at Add and record which events can change its answer; re-evaluate only on those
  events (`ConstructFunction` + `arg.events` → `loadEvents[event][id]`; WA:786-904, :3067-3075).
- Gather world state once per scan and pass it as a flat tuple to every predicate (WA:1557-1615).
- Tri-state armed store (`true/false/nil`) and "changed count" gate before any load/unload work (WA:1633-1647).
- Create the display object lazily at first arm, tear it down at disarm (WA:1620, :1914-1918).
- Zone events parked while the world map is open and replayed on close — a client-specific hazard already solved (WA:1742-1772).
- Login as a coroutine with per-frame µs budgets and self-hiding OnUpdate (WA:4245-4363).
- Post-login squelch window for side effects (WA:1262, :1319-1324).

**POSTURE NOT TO INHERIT**
- 25+ always-registered load events on a permanent frame regardless of whether any aura's predicate depends on them (WA:1692-1724);
  fine at WA's scale, unnecessary for a single-purpose addon.
- Load predicates as generated source strings run through `loadstring` (WA:3078; AE:648) — a general-purpose-authoring choice,
  not needed when the predicate set is fixed in code.
- Every load-time re-scan re-reads ~30 API values even when the event could only change one of them (WA:1557-1601).

---

## 2. TRIGGERS — registration, dispatch, CLEU

**Trigger systems are pluggable.** `WeakAuras.RegisterTriggerSystem(types, triggerSystem)` (WA:4367-4372) maps trigger `type` →
system; each system implements `Add/LoadDisplays/UnloadDisplays/UnloadAll/FinishLoadUnload/Delete/Rename/GetTriggerConditions/
CreateFallbackState/...` (dispatch helper `wrapTriggerSystemFunction`, WA:3719-3777). Two shipped: GenericTrigger (event/status/
custom) and BuffTrigger2 (auras). BossMods.lua adds boss-mod prototypes into GT.

**GenericTrigger — compile at Add, index at Load.**
- At `GenericTrigger.Add` the trigger is compiled into `events[id][triggernum] = { triggerFunc, untriggerFunc, statesParameter,
  events, internal_events, unit_events, subevents, force_events, durationFunc, loadFunc, counter, ... }` (GT:1871-1901). Event
  lists come from `Private.event_prototypes[...]` fields `events` (shape `{events = {...}, unit_events = {unit = {...}}}`),
  `internal_events`, `force_events`, each possibly a function of `(trigger, untrigger)` (GT:1713-1738).
- At load, `LoadEvent(id, triggernum, data)` (GT:1387-1442) writes the **event → aura → trigger index**:
  `loaded_events[event][id][triggernum] = data` (GT:1398-1399); CLEU is one level deeper
  `loaded_events["COMBAT_LOG_EVENT_UNFILTERED"][subevent][id][triggernum]` (GT:1391-1396); unit events expand `group/raid/party/
  boss/arena/nameplate` to concrete unit ids via `MultiUnitLoop` (GT:1321-1385) into `loaded_unit_events[unit][event][id][triggernum]`
  (GT:1419-1437); a `loadInternalEventFunc` computes extra internal events at load time (GT:1410-1418); prototype `loadFunc` starts
  watchers (GT:1439-1441).
- Frame registration is **lazy and additive**: `GenericTrigger.LoadDisplays` collects not-yet-registered events into `eventsToRegister`
  (GT:1460-1462) and calls `pcall(frame.RegisterEvent, frame, event)` once per new event on a single frame (GT:1496-1499);
  unit events get **one frame per unit id** with `RegisterEvent(event, unit)` (GT:1503-1510). `FRAME_UPDATE` is diverted to the
  every-frame updater (GT:1458-1459, :1489-1493). After load: `ScanWithFakeEvent(id)` replays `force_events` (GT:1514-1516,
  :1166-1195) and the load-triggering event is replayed if it was newly registered (GT:1518-1525 "Replay events that lead to loading").
- **Events are never unregistered** in GT (no `UnregisterEvent` in the file; sub-audit grep). Unload only nils index entries
  (`UnloadDisplays` GT:1248-1272; `UnloadAll` GT:1239-1246 `wipe(loaded_events)`, cancels delayed timers, unregisters every-frame).
  Consequence: once any aura in the session registered e.g. `UNIT_HEALTH`, the frame stays registered until reload; the cost per
  fire is then the `HandleEvent` → `ScanEvents` early-exit path.

**Dispatch.** `HandleEvent(frame, event, arg1, arg2, ...)` (GT:1197) → `if not WeakAuras.IsPaused()` → `Private.ScanEvents(event,
arg1, arg2, ...)` (GT:1205-1207). `Private.ScanEvents` (GT:885-902): `local event_list = loaded_events[event]; if not event_list then
return` (GT:888-892) — this is the "don't evaluate every trigger" mechanism: iteration is only over auras indexed under that exact
event key. `Private.ScanEventsInternal` (GT:968-999) iterates `for id, triggers in pairs(event_list)` / `for triggernum, data in
pairs(triggers)`, wraps each aura in `StartProfileAura` + `ActivateAuraEnvironment`, runs `RunTriggerFunc`, and calls
`Private.UpdatedTriggerState(id)` **once per aura per event** only if any trigger reported change (GT:993-995). Per-trigger
optional `delay` (`GenericTrigger.GetDelay`, GT:4058-4069) defers via `Private.RunTriggerFuncWithDelay` (GT:1005-1046, timers
tracked in `delayTimerEvents[id][triggernum]`, cancelled on unload GT:1269). `FRAME_UPDATE` branch has a per-trigger
`onUpdateThrottle` (GT:956-966, :974-980). Unit events: `Private.ScanUnitEvents(event, unit, ...)` (GT:911-949) looks up
`loaded_unit_events[unit][event]`; `HandleUnitEvent` first does `if frame.unit ~= unit then return` (GT:1229) — filtering is in Lua
because the fork has no `RegisterUnitEvent` (sub-audit; only comment mentions at GT:1791, `Types.lua:3510`).

**Deferral queue for re-entrancy.** All public `WeakAuras.ScanEvents/ScanUnitEvents/ScanEventsByID/ScanEventsInternal` go through
`scannerFrame:Queue(...)` and run on the next OnUpdate (GT:849-869, :904-909); the frame hides itself when the queue is empty
(GT:861-863; comment GT:858 "a joker dispatched an event in in trigger code"). Internal `Private.*` variants are synchronous.
Composed IDs: `Private.ScanEventsByID(event, id)` scans both `event` and `event..":"..id` keys (GT:871-879).

**CLEU specifically.**
- No `CombatLogGetCurrentEventInfo` anywhere; args arrive as varargs, `arg1` = timestamp, `arg2` = subevent (GT:1197, :1206);
  prototype documents `-- {}, -- we don't have hideCaster` (`Prototypes.lua:3170-3173`), so generated function signature is
  `function(state, event, _, _, sourceGUID, ...)` (GT:371-372).
- Two early exits: no CLEU triggers at all (`loaded_events["COMBAT_LOG_EVENT_UNFILTERED"]` nil, GT:888-892) and no trigger for
  **this subevent** (`event_list = event_list[arg2]; if not event_list then return`, GT:893-899).
- Registration granularity: the frame registers `COMBAT_LOG_EVENT_UNFILTERED` once (a single game-level registration); subevent
  selectivity is entirely in the Lua index. Custom triggers must name a subevent — unfiltered CLEU is refused with a warning
  (GT:1842-1846 "We don't register CLEU events without parameters anymore"; GT:1906-1908 "very performance costly");
  subevent validity via `Private.IsCLEUSubevent` (WA:5849-5865, prefix×suffix tables).
- Second CLEU consumer: swing-timer frame, own `RegisterEvent` (GT:2195), args `(ts, event, sourceGUID, _, _, destGUID, ...)`
  (GT:2081) confirming the 3.3.5 layout.
- Known defect (sub-audit): `GenericTrigger.Rename` copies CLEU subevent registrations backwards (`subevents[oldid] =
  subevents[newid]; subevents[oldid] = nil`, GT:1299-1300) — a renamed aura with a CLEU trigger loses its loaded registration.

**Cost model summary (trigger layer).**
- Per event fire: `HandleEvent` (a `"generictrigger " .. event` string concat happens before any filtering, GT:1198, :887 — even
  when profiling is off, since only the callee is swapped to `doNothing`, P:268) → one or two table lookups → per indexed aura:
  env activation + trigger func + state diff.
- Per frame: only if some loaded trigger asked for `FRAME_UPDATE` (refcounted, GT:1928-1960) or a prototype watcher installed an
  OnUpdate (`Watch*` frames — cooldown GT:2722, nameplate target :3766, mounted :3803, moving :3836, in-range :3864, nameplates
  :3947, item count :3969) — these prototype watchers have **no `unloadFunc`** and are never torn down (sub-audit).
- Never: auras whose events are not indexed.

**REUSABLE MECHANISM**
- Event-keyed index `loaded_events[event][id][trigger]`, with an extra key level for CLEU subevents, and an O(1) miss path
  (GT:885-899, :1387-1400).
- Register game events lazily and additively as triggers arm; per-unit filtering by a frame-per-unit + `frame.unit ~= unit` guard
  when the client lacks `RegisterUnitEvent` (GT:1496-1510, :1229).
- Aggregate "did anything change" per aura per event and run the state machine once (GT:972-995).
- Deferred re-entrant dispatch queue that self-hides (GT:849-869).
- Replay the arming event on arm ("Replay events that lead to loading", GT:1518-1525) and a `force_events` fake scan so state
  is correct immediately after arm (GT:1166-1195, :1514-1516).
- Per-trigger `onUpdateThrottle` and optional `delay` (GT:956-966, :1005-1046).
- Refuse the unbounded firehose (unfiltered CLEU) at authoring time (GT:1842-1846, :1906-1908).

**POSTURE NOT TO INHERIT**
- Never unregistering events once registered (GT `UnloadDisplays`/`UnloadAll` only touch Lua indexes) — acceptable for an addon
  meant to have "something" loaded always; wrong for an addon that should be inert outside its route.
- Prototype watchers with `loadFunc` but no `unloadFunc` (sub-audit) — one-way arming.
- Per-event string concatenation for profiling labels on the hot path even with profiling off (GT:887, :1198).
- Generic `pcall(frame.RegisterEvent, ...)` to tolerate unknown events on this client (GT:1497) — masks typos; only justified when
  the event list is user-authored.
- Frame-per-unit fan-out (`nameplate1..100`, `raid1..40`; GT:1331-1357, :1503-1510) — WA needs it because auras can watch any
  unit; a route driver watches the player.

---

## 3. STATE — what is held per trigger, how transitions are detected, how it is confined

**Per-aura record.** `triggerState[id]` (WA:351; built at WA:3108-3117): `disjunctive` (any/all/custom), `numTriggers`,
`activeTriggerMode`, `triggerLogicFunc`, `triggers = {}` (per-trigger boolean "is firing"), `activationTime`, `triggerCount`,
`activatedConditions`, plus `[triggernum] = allStates` (clone-keyed state table with `Private.allstatesMetatable`,
WA:4384-4387; metatable from `TSUHelpers.lua:140-150`), `show`, `activeStates`, `fallbackStates`.

**Per-trigger state = `allStates[cloneId] = state`.** A `state` is a plain table the trigger system fills; the machine only
requires `show` and `changed`, and it stamps `state.trigger/triggernum/id` itself (WA:4723-4725). GT's `Private.ActivateEvent`
sets `show = true` and writes `duration/expirationTime/progressType/autoHide/name/icon/texture/stacks/...` **only when the value
differs**, setting `changed` per real delta (GT:528-639); `Private.EndEvent(state)` sets `show = false; changed = true` and does
**not** delete (GT:451-461). BT2's `UpdateStateWithMatch` likewise sets `state.changed = true` on field deltas (BT2:551…, e.g. :774,
:956, :967). TSU/custom "full" triggers mutate through metatable methods (`Update/Replace/Remove/RemoveAll/Get/IsChanged/SetChanged`,
`TSUHelpers.lua:140-150`) each of which sets both `state.changed` and a per-table changed flag (`changedStates`,
`TSUHelpers.lua:130-138`); `RunTriggerFunc` reads `allStates:IsChanged()`, then resets and **type-validates** every state (GT:655-674,
wiping on "All States table contains a non table").

**Transition detection = dirty flags, evaluated in one pass.** `Private.UpdatedTriggerState(id)` (WA:4711-4817):
1. per trigger, per clone: `if state.changed then startStopTimers(...)`, `anyStateShown = anyStateShown or state.show`
   (WA:4722-4731) → `applyToTriggerStateTriggers` flips `triggers[triggernum]` and adjusts `triggerCount`, `activationTime`
   (WA:4592-4606);
2. only if any trigger flipped (`changed`) or `show == nil` is the combination re-evaluated (`evaluateTriggerStateTriggers`,
   WA:4608-4635: `any` → `triggerCount > 0`; `all` → `== numTriggers`; `custom` → sandboxed `triggerLogicFunc(triggers)`; options
   open → ignore combination WA:4611-4614);
3. active trigger = `activeTriggerMode` or first-active scan (WA:4744-4753); if the active trigger has no shown state, a
   `CreateFallbackState` (WA:3976-4001) supplies a synthetic one so the region still shows;
4. apply by comparing `show` vs `oldShow` — Hide→Show applies states to regions; Show→Hide collapses region + clones;
   Show→Show collapses clones no longer present then applies (WA:4782-4805). `ApplyStatesToRegions` computes
   `applyChanges = not region.toShow or state.changed or region.state ~= state` and per-trigger `region.states[n]` identity/changed
   checks (WA:4637-4679); only then `region:Update()`, subregion `Notify("Update")`, `region:Expand()`, parent `ActivateChild`,
   `Private.RunConditions` (WA:4574-4586, :4670-4673);
5. GC + reset: `if not state.show then triggerState[id][triggernum][cloneId] = nil end; state.changed = false` (WA:4807-4814);
6. `Private.SendDelayedWatchedTriggers()` — trigger-observes-trigger fan-out is deferred to **after** the state machine has settled
   (WA:4816; queue WA:4683-4709; observer scan GT:1049-1074).

**Autohide timers are derived from state, deduped.** `startStopTimers` (WA:4520-4572) keeps `timers[id][triggernum][cloneId] =
{handle, expirationTime, state}` and reschedules only `if record.expirationTime ~= expirationTime or record.state ~= state`
(WA:4548); expiry sets `show=false, changed=true` and re-enters `UpdatedTriggerState` (WA:4554-4567).

**Confinement.** State exists only for loaded auras: `LoadDisplays` resets the header fields (WA:1854-1858); `UnloadDisplays`
`wipe(triggerState[id][i])` + `show = nil` + timers cancelled + conditions unloaded + region/clones collapsed (WA:1890-1925);
`UnloadAll` wipes every trigger table and all timers (WA:1787-1804); `Private.Pause()` first hides all states via
`SetAllStatesHidden` and pushes the machine (WA:1360-1372). `Private.SetAllStatesHidden(id, triggernum)` = `show=false;
changed=true` for every clone, returning whether anything was visible (WA:3336-3345). BT2 keeps its own match cache
(`matchData`, `matchDataUpToDate`) but wipes per-aura scan funcs on unload (`UnloadAura`, BT2:2030-2081; `UnloadAll` BT2:2082-2113
wipes 17 tables) and cleans per-unit caches when units vanish (BT2:1963-1967).

**Region-side state.** The region receives `region.state` (active trigger's state for its clone) and `region.states[n]` for every
trigger incl. `-1` = global-condition state (WA:4651-4667); regions must expose `Update()`; state on hide is nilled
(`region.states = nil; region.state = nil`, RP:1000-1001, :1032-1033); clones are pooled per regionType (`clonePool`, WA:3185-3196,
`Private.ReleaseClone` WA:3357-3368 — refuses to pool a clone that has become `IsProtected()`).

**REUSABLE MECHANISM**
- A state = plain table with `show` + `changed`; producers set `changed` only on real deltas (GT:528-639) so the machine can skip work.
- One `UpdatedTriggerState(id)` pass: dirty-flag sweep → per-trigger boolean → combination only when a boolean flipped → apply by
  old/new `show` comparison → GC hidden states → reset flags (WA:4711-4817).
- Fallback state when a trigger is "on" but supplied no state (WA:3976-4001) — the display never depends on the producer being
  complete.
- Timers rescheduled only when expiration/state identity changes (WA:4548).
- Deferred trigger-observes-trigger fan-out after settle (WA:4816, :4698-4709).
- Unload = wipe the per-id state tables, cancel per-id timers, collapse displays — the state footprint of an unarmed thing is zero
  (WA:1877-1925).

**POSTURE NOT TO INHERIT**
- Multi-trigger combination (`any/all/custom` + `activeTriggerMode` + fallback) — WA's product is N independent triggers per display;
  a route driver has one truth per stage.
- Clone-keyed state tables and clone pooling (WA:3185-3196, :3357-3368) exist to render one display per unit/aura instance.
- Options-open special cases woven through the machine (`WeakAuras.IsOptionsOpen()` at WA:4611, :4699, :3031, :3119).

---

## 4. CONDITIONS → ACTIONS

**Conditions are compiled to one function per aura.** `ConstructConditionFunction(data)` (C:734-826) emits Lua source:
locals `newActiveConditions/propertyChanges/nextTime`, `return function(region, hideRegion)`, `state = region.states` (C:745-758);
**loop 1** — for each condition, `if (<check>) then newActiveConditions[n] = true` (`CreateCheckCondition`, C:454-474; `linked`
conditions chain as `elseif`, C:460-461); **recheck** — timer-typed checks emit code that computes the next moment the answer can
change (`nextTime`), and the function ends with `Private.ExecEnv.ScheduleConditionCheck(recheckTime, uid, cloneId)` or
`CancelConditionCheck` (C:776-780; scheduler C:189-210 dedupes per uid/clone and only re-runs `if region.toShow`); **loop 2** —
deactivation: `if activatedConditions[n] and not newActiveConditions[n]` → restore base property values (C:505-531); **loop 3** —
activation: `if newActiveConditions[n]` and not previously active → set `propertyChanges[prop]` or call `region:<action>(...)`
(setters vs actions distinguished by `propertyData.setter` vs `.action`, C:533-603; already-active → only override properties,
C:581-596); **apply** — one `region:<setter>(value)` per property that changed, sub-regions via `region.subRegions[i]:` (C:801-822).
Loaded via `Private.LoadFunction` (built-in sandbox) into `checkConditions[uid]` (C:838-845). Per-check code shapes: `number`,
`timer` (remaining = `expirationTime - now`, with paused/remaining properties, C:319-333), `elapsedTimer`, `select`, `bool`,
`string` (`==`, `find` plain, `match`), `range` (loops group/nameplates through `WeakAuras.CheckRange`, C:350-396), `customcheck`
(user Lua, C:297-310), `alwaystrue`; every state test is guarded `state[t] and state[t].show and state[t][var] ~= nil and`
(C:271-272). Condition variables come from the trigger systems (`GetTriggerConditions`, WA:3939) so a trigger declares what its
state exposes.

**When conditions run.** (a) after every state application, `Private.RunConditions(region, uid, not state.show)` (WA:4672;
also RP:984, :1014 on hide) — i.e. only when trigger state actually changed; (b) on the timer-recheck computed above; (c) on
"dynamic" events for global conditions (`incombat` ← `PLAYER_REGEN_*`, `hastarget`/`attackabletarget` ← `PLAYER_TARGET_CHANGED`…,
`rangecheck` ← `WA_SPELL_RANGECHECK`, C:688-728): `RegisterForGlobalConditions(uid)` indexes `dynamicConditions[event][uid]`
(C:941-1030), registers the event on a lazily-created frame (C:1000-1005, :1025), and unit-scoped events get a frame per unit
(C:1014-1023); `customcheck` conditions can name events in their `op` field (C:951-960). Handler `runDynamicConditionFunctions`
re-runs conditions only for **active** auras' active states (C:873-888). `FRAME_UPDATE`/`WA_SPELL_RANGECHECK` install an OnUpdate
that is removed when no condition needs it (C:1007-1012, :1040-1046); the range check inside it is throttled to 0.2 s (C:930-937).
Unload: `Private.UnloadConditions(uid)` cancels timers and unregisters events whose subscriber set went empty (C:1032-1053, :1077-1080).

**Actions.** `Private.PerformActions(data, when, region)` (WA:3650-3708) is called from `region:Expand()` (`"start"`) and
`region:Collapse()` (`"finish"`) (RP:1047, :1085, :1100, :1151). Bails `if paused or WeakAuras.IsOptionsOpen()` (WA:3651).
Kinds: chat/print message (`Private.HandleChatAction`, WA:3370-3422 — `PRINT`, `TTS`, `ERROR`, `COMBAT`, `WHISPER`, `SMARTRAID`
picking BG/RAID/PARTY/SAY, else channel; every `SendChatMessage` is wrapped in `pcall`), sound stop/play (`region:SoundPlay`,
RP:211-…; `SoundPlayHelper` refuses `if WeakAuras.IsOptionsOpen() or Private.SquelchingActions()` RP:167), custom Lua in the
sandbox with `xpcall` (WA:3684-3691), glows on unit frames / nameplates / named frames / parent (`Private.HandleGlowAction`,
WA:3569-3648 with per-frame hide-funcs and a monitor for unit-frame changes). Text placeholders `%c`, `%p`, … resolved from state
(`Private.ReplacePlaceHolders`, WA:5061). Region-property changes from conditions are **not** actions — they are setter calls made
inside the compiled condition function (C:801-822).

**Throttle / debounce inventory.**
- Login squelch (`squelch_actions`, WA:284, :1319-1324) — sounds/TTS silenced ~10 s.
- Condition timer-recheck computes the *exact* next time and dedupes (C:189-210, :415-448) rather than polling.
- Range dynamic condition polled at 0.2 s (C:933-936).
- Trigger `delay` (GT:1005-1046) and `onUpdateThrottle` (GT:956-966).
- Sound repeat loop bounded by `Private.maxTimerDuration` (RP:229).
- No generic debounce on actions: every Expand fires `start` actions, every Collapse `finish` (RP:1041-1092).

**REUSABLE MECHANISM**
- Conditions compiled to one function that (1) computes which are active, (2) computes the next time any timer-typed check can
  flip and schedules exactly that, (3) diffs against last-active to emit only deltas (C:734-826, :189-210).
- Conditions run only when producer state changed or on their declared events, never per frame unless a condition asks
  (WA:4672; C:941-1053).
- Every state read guarded by `state and state.show and var ~= nil` (C:271-272).
- Side effects gated by a global squelch + paused/options flags, and every outbound chat call `pcall`'d (WA:3651, :3407-3420;
  RP:167).
- Setter-vs-action distinction: properties are restored to base when the condition ends; actions are fire-once on edge
  (C:505-531, :533-603).

**POSTURE NOT TO INHERIT**
- Chat-channel announcements (`SAY/RAID/WHISPER/SMARTRAID`, WA:3399-3420) — a raid-communication feature; irrelevant and noisy for a
  personal route driver.
- Glowing third-party unit frames / nameplates via LibGetFrame / LibCustomGlow (WA:3569-3648).
- User-authored `customcheck` Lua in conditions (C:297-310).

---

## 5. FRAME BUDGET — OnUpdate work, timers, chunking, profiling

**Per-frame consumers and whether they stop.**
| frame | file:line | runs when | stops itself? |
|---|---|---|---|
| Animations `UpdateAnimations` | An:178-203 | `frame:SetScript("OnUpdate", UpdateAnimations)` at file load; body returns at once `if not updatingAnimations` (An:180-182) | **No** — the script is never removed; `updatingAnimations` is set true (An:208, :408) and only becomes false when the animation table empties (checked inside; sub-audit grep found no `= false` outside the loop's own tail); the OnUpdate call itself is paid every frame |
| Region `FrameTick` (subscriber-counted) | RP:906-918, :664-670 | `Private.FrameTick:SetOnSubscriptionStatusChanged("Tick", …)` installs the OnUpdate **only while** `HasSubscribers("Tick")`, else `SetScript("OnUpdate", nil)` (RP:912-917); a region subscribes only if a subregion asked for `FrameTick` **and** it is shown (`UpdateTick`, RP:664-670) | **Yes** |
| GT every-frame updater | GT:1921-1971 | created lazily; refcount `update_clients_num`; installed by `RegisterEveryFrameUpdate`, cleared at zero (GT:1951-1960) | **Yes** |
| GT `scannerFrame` (deferred dispatch) | GT:849-869 | shown on `Queue`, hides when queue drained (GT:861-863) | **Yes** |
| Conditions dynamic frame | C:1007-1012, :1040-1046 | OnUpdate only for `FRAME_UPDATE`/`WA_SPELL_RANGECHECK` conditions; removed when both sets empty | **Yes** |
| BT2 `Buff2Frame` OnUpdate | BT2:2005-2027 | always installed; body: `if next(matchDataChanged) then UpdateStates(...); wipe(matchDataChanged) end` (BT2:2010-2014); group polling every 1.0 s only `if next(pollingScanFuncs)` (BT2:2016-2025) | **No** (permanent, but O(1) when idle) |
| Threads scheduler | WA:4346-4362 | hidden at size 0; shown on Add; toggled by combat events | **Yes** |
| Mouse-anchor frame | WA:5416-5426 | `moveWithMouse` OnUpdate only after options close and only if the mouse frame exists (created on first `MOUSE` anchor, WA:5349) | partial (persists once created) |
| Prototype watchers | GT:2722, :3766, :3803, :3836, :3864, :3947, :3969 | installed by `loadFunc` (some self-clear, e.g. mounted GT:3788-3790, item count :3959/:3973) | mostly **No** on unload (no `unloadFunc`) |
| Profiling window | P:719 | only while window shown | Yes |
| LDB icon color / tooltip | WA:1082, :1095 (cleared :1107-1108) | while tooltip shown | Yes |

**(a) BT2's dirty-per-event / drain-once-per-frame batching (explicit).** Every `UNIT_AURA` and related event runs `EventHandler`
(BT2:1870-1970) which **only** marks: `ScanUnit(time, unit)` → `ScanGroupUnit` → `ScanUnitWithFilter` (BT2:1618-1657) rescans that
unit's auras into `matchData` and, for every trigger whose match set changed, sets `matchDataChanged[id][triggernum] = true`
(BT2:236-237, :255-256, :280-281, :426-427, :1535-1536, :1570-1571, :1591-1592, :1611-1612, :1834-1835, :1852-1853). No trigger state is
built in the event handler. Then, once per frame, `Buff2Frame`'s OnUpdate drains: `if next(matchDataChanged) then UpdateStates(matchDataChanged,
time); wipe(matchDataChanged) end` (BT2:2005-2014); `UpdateStates` (BT2:1659-1671) calls `UpdateTriggerState(time, id, triggernum)`
per dirty trigger and `Private.UpdatedTriggerState(id)` once per aura if anything updated. So N `UNIT_AURA` bursts within a frame cost
N cheap scans but **one** state build and one region apply. `PrepareMatchData(unit, filter)` (BT2:1541-1557) lazily rescans a unit
only `if not matchDataUpToDate[unit][filter]`; the flag is invalidated on `UNIT_AURA` (BT2:1622-1623) and unit removal (BT2:1966).
Also gated `if WeakAuras.IsPaused() then return` (BT2:2006-2008).

**(b) Animations vs FrameTick (explicit contrast).** `Animations.lua` installs its OnUpdate unconditionally at load
(`frame:SetScript("OnUpdate", UpdateAnimations)`, An:203) and relies on an early return flag (`if not updatingAnimations then return`,
An:180-182) — the per-frame Lua call is always paid, the loop body is not. It also carries dynamic-group positioning:
`Private.RegisterGroupForPositioning(uid, region)` parks a group in `pending_controls` and sets `updatingAnimations = true`
(An:205-211); the loop calls `groupRegion:DoPositionChildren()` for each pending group before running animations (An:185-188).
`RegionPrototype`'s `Private.FrameTick` is a `SubscribableObject` (RP:909); its OnUpdate script is **installed and removed** by the
subscription-status callback (RP:912-917), and each region adds/removes itself only when a subregion needs a tick and the region is
visible (RP:664-670; re-evaluated on `Expand/Collapse` via `region:UpdateTick()`, RP:1056, :1091, :1113, :1160). Same file, two
postures: flag-guarded permanent OnUpdate vs subscriber-counted OnUpdate that ceases to exist.

**Timers.** `WeakAuras.timer` = AceTimer-3.0 embedded into the global `WeakAurasTimers` (WA:38-39, :86-87); no `C_Timer` in the
addon (sub-audit; the fork lacks it). Uses: autohide (WA:4554), delayed triggers (GT:1023-1027), condition rechecks (C:199),
GT scheduled scans deduped by `scheduled_scans[event][fireTime]` firing at `fireTime - GetTime() + 0.1` (GT:4013-4042), anchor
retry 1 s (WA:5675), fake-state refresh 1 s while options open (WA:4456), squelch end (WA:1323), BT2 tooltip refresh 3 s after login
(BT2:1950-1954), BT2 per-trigger `nextScheduledCheckHandle` (BT2:2036-2039).

**Chunking / deferral.** Coroutine `threads` with µs budgets per priority pool (WA:4245-4363; `runThreadPool` measures with
`debugprofilestop()` and stops when the next estimated step would overrun, WA:4306-4334; per-thread estimates come back from
`coroutine.yield(estimate, label)`, WA:4325-4327). Used for login (WA:1171-1239), DB repair (WA:2232-2253), `AddMany` incl.
dependency sort / modernize / add / anchor (WA:2440-2545), options spell cache (`Options/Cache.lua:80-103`, `background`),
options update flow (`Options/OptionsFrames/Update.lua:761-825`). Dynamic groups batch sort/position/resize behind `Suspend()/Resume()`
with `needToReload/needToSort/needToPosition/needToResize` flags replayed in `RunDelayedActions` (DG:1110-1143; `IsSuspended` also
true until login finished, DG:1106-1108); `PauseAllDynamicGroups/ResumeAllDynamicGroups` bracket bulk operations
(WA:1386-1404, e.g. :1826/:1847, :4416/:4439). Positioning of animated groups is deferred one frame through the animation loop
(DG:1344-1361 → An:205-211).

**Profiling hooks — what WA considers expensive.** `Profiling.lua` measures wall time via `debugprofilestop()` per named system and
per aura, with re-entrancy count and max spike (P:133-160); enabling swaps `Private.StartProfileSystem/Aura/UID` from `doNothing`
to real (P:245-273); `PrintProfile` reports total, "Time spent inside WA", every aura sorted spike-first, colour-ramped spikes at
2/2.5/3 ms (P:311-349, :380-455). Systems labelled (i.e. what the authors chose to watch): `"load"` (WA:1728…), `"generictrigger
<event>"` / `"generictrigger <event> <unit>"` (GT:887, :912, :1198), `"bufftrigger2 - <event>"` / `"- OnUpdate"` (BT2:1871, :2009),
`"dynamic conditions"` (C:899, :919), `"animations"` (An:183), `"dynamicgroup"` (DG:1192, :1302, :1520, :1563), `"sound"`, `"frame
tick"` (RP:151, :159, :908), `"model"`, `"stopmotion"`, `"custom region anchor"` (WA:5760), `"boss_guids"` (WA:1408), plus per-aura
brackets around every trigger evaluation and condition run. Also `WeakAuras.ProfileFrames`/`ProfileDisplays` via
`GetFrameCPUUsage` over the `Private.frames` registry (WA:4101-4127; registry `Init.lua:5`, ~26 named frames). Real-time window
`P:16-19`, `:544-569`, `:719`. Auras that call `WeakAuras.GetData` >99 times get a warning ("slow function", AE:486-489); custom
saved data >16 KB warns (AE:227-235).

**REUSABLE MECHANISM**
- Dirty-mark in the event handler, build state once per frame from the dirty set (BT2:1870-2014).
- Per-unit "up to date" flag → lazy rescan only when invalidated (BT2:1541-1557, :1622-1623).
- Subscriber-counted OnUpdate that installs/removes the script rather than flag-guarding it (RP:906-918, :664-670).
- Refcounted every-frame updater (GT:1928-1960); self-hiding deferred queue (GT:849-869).
- Coroutine work with per-frame µs budgets measured by `debugprofilestop()` and self-reported step estimates (WA:4306-4353).
- Compute the exact next recheck time and schedule one timer, dedupe on identical fire times (C:189-210; GT:4013-4027).
- Suspend/Resume with need-flags for bulk operations (DG:1110-1143).
- Named-system + per-thing profiling with re-entrancy count and spike, function-swap to zero cost when off (P:133-160, :245-273);
  a named-frame registry for `GetFrameCPUUsage` (Init.lua:5, WA:4101-4127).

**POSTURE NOT TO INHERIT**
- Permanent OnUpdate scripts that early-return (An:180-203; BT2:2005) — cheap at WA's scale, but the pattern (a) still pays the
  script call per frame and (b) hides which subsystems are live.
- Prototype watchers that install OnUpdate/events on `loadFunc` with no teardown.
- The 100-nameplate / 40-raid loops (GT:1331-1357; C:373-374).
- Options-driven fake-state ticker (WA:4415-4457) — authoring UI concern.

---

## 6. NON-INVASIVENESS — what WA refuses to do; how it stays out of the way

**No gameplay input, by construction.** No `CastSpell*`, `UseAction`, `RunMacro*`, `SecureCmdOptionParse`, or secure-template
creation anywhere in the core (grep over WA/GT/BT2/RP/AE for these names returns nothing; the only "action" surfaces are chat, sound,
glow, custom Lua — WA:3650-3708). Frames are plain `CreateFrame("Frame")` children of `WeakAurasFrame` (`SetAllPoints(UIParent)`,
`SetFrameLevel(0)`, WA:1242-1245); regions are hidden until state says otherwise (WA:3206-3211).

**Sandbox for user code (`AuraEnvironment.lua`).** All custom Lua (triggers, conditions, actions, text) is `loadstring`'d and
`setfenv`'d into `exec_env_custom` (AE:640-672); built-in generated code (load funcs, condition funcs) into `exec_env_builtin`
(AE:591-630, :674-676). The custom env blocks by name: `getfenv/setfenv/loadstring/pcall/xpcall`, `SendMail`, trade-money APIs,
`RunScript`, `AcceptTrade`, `EditMacro/CreateMacro/SetBindingMacro`, `RegisterNewSlashCommand`, `hash_SlashCmdList`, `GuildDisband/
Uninvite`, `securecall`, `DeleteCursorItem`, `ChatEdit_*` (AE:151-184) and tables `SlashCmdList`, mail frames, `DEFAULT_CHAT_FRAME`,
`ChatFrame1`, `WeakAurasSaved`, `WeakAurasOptions*` (AE:186-196); a blocked access returns a no-op function / empty table and raises
an aura warning `"Forbidden function or table: %s"` (AE:390-393, :541-546). `WeakAuras` itself is exposed read-only through
`MakeReadOnly` with a further blocklist (`Add/Delete/Import/Rename/...`, AE:428-513) and `GetData` returns a **copy** (AE:482-493).
Writes to `aura_env` are refused; overwriting any `_G` name warns (AE:565-579). Frame lookups by user-supplied name go through
`Private.GetSanitizedGlobal` = the sandbox env (AE:678-679; used for anchors WA:5751 and glows WA:3592). Function strings are cached
weakly by source text (AE:640-668). Every custom call is wrapped `pcall`/`xpcall` with an error handler that attributes the error to
the aura and prints WA + aura versions (WA:96-135; e.g. WA:3688, :1816, C:850, GT trigger funcs).

**Combat lockdown handling.**
- Options load: `if InCombatLockdown() then` "Options will finish loading after combat ends" → queued on `PLAYER_REGEN_ENABLED`
  (WA:139-160, :1331-1339).
- Import in combat deferred the same way (T:499-508).
- Show/hide of a region that has become **protected** (e.g. a user anchored/parented it into a secure frame): `if region:IsProtected()
  then if InCombatLockdown() then` → error warning "Cannot change secure frame in combat lockdown", no `Show()/Hide()` call;
  out of combat → warning + proceed (RP:1017-1030, :1070-1083, :1136-1149). Clones that became protected are not returned to the pool
  (WA:3363-3367). `region.SetParent` is `pcall`'d during anchoring (WA:5796-5799).
- Threads scheduler pauses its OnUpdate on `PLAYER_REGEN_ENABLED` and resumes in combat only if work is pending (WA:4354-4362).
- Encounter bookkeeping persists boss GUIDs so a reload mid-fight can re-detect the encounter (`CheckForPreviousEncounter`,
  WA:1153-1169).

**Staying out of the way otherwise.** All outbound chat is `pcall` (WA:3407-3420); sounds are squelched after login and while options
open (RP:167, WA:1319-1324); `PerformActions` is skipped when paused or options open (WA:3651); missing anchor frames fall back to a
hidden frame or the parent rather than erroring (WA:5726, :5772, :5776); mouse-anchor frame at strata FULLSCREEN is only visible in
options (WA:5363, :5394); a hooked `SetItemRef` handles WA chat links but whispers from strangers are filtered (T:143-183, :215).
Nothing hooks protected functions; the only `hooksecurefunc` in core is `SetItemRef` (T:215) plus `WorldMapFrame:HookScript("OnHide")`
(WA:1764).

**REUSABLE MECHANISM**
- Plain frames under one root frame at level 0, hidden by default; all effects are visual/audio/print (WA:1242-1245, :3206-3211).
- `IsProtected()` + `InCombatLockdown()` check before `Show/Hide` with a warning path instead of an error (RP:1017-1030).
- Defer UI-heavy work (options, import) to `PLAYER_REGEN_ENABLED` (WA:144-148, :1331-1339).
- `pcall` every side effect that can taint or throw (`SendChatMessage`, `SetParent`, `RegisterEvent`) (WA:3407, :5796; GT:1497).
- Error handler that attributes to the unit of work and adds version context (WA:96-135).

**POSTURE NOT TO INHERIT**
- The user-code sandbox (AE:151-679) — WA needs it because it ships arbitrary Lua from strangers; an addon with no user Lua needs no
  `setfenv` machinery.
- Chat-link / whisper transport and stranger filtering (T:143-215).
- Warning-not-refusal on protected frames (RP:1023-1026 shows the frame anyway out of combat) — WA tolerates users doing odd anchoring;
  a driver should simply never parent into secure frames.

---

## 7. IMPORT / EXPORT — libraries, format, Modernize, validation

**Libraries.** `Transmission.lua:201-205` pulls `LibCompress`, `LibDeflate`, `AceSerializer-3.0`, `LibSerialize`, `AceComm-3.0`.
Only `Archivist` (with its own embedded `LibStub` + `LibDeflate`, `Libs/Archivist/Archivist.xml:2-3`) and `LibCustomGlow-1.0` are
shipped (`embeds.xml:3-4`); the rest resolve from the client's global LibStub (`WeakAuras.toc:23` lists them as `OptionalDeps`;
`Init.lua:58-99` checks presence, prints on failure, and every module gates on `WeakAuras.IsLibsOK()`, e.g. T:21). Note `Init.lua:80`
tests the string literal not the lib for the standalone list (always truthy).

**Format.** Export `TableToString` (T:255-282): `LibSerialize:SerializeEx({errorOnUnserializableType=false}, tbl)` (T:256, :208-210) →
`LibDeflate:CompressDeflate(serialized, {level = 9})` (T:263, :207) → prefix `"!WA:2!"` (T:275) + `EncodeForPrint` (chat) or
`EncodeForWoWAddonChannel` (T:277-279); result memoized 300 s (T:253, :271). Import `StringToTable` (T:284-337) sniffs the version:
`!WA:N!` → LibDeflate+LibSerialize (v≥2); leading `!` → LibDeflate+AceSerializer (v1); else base64+LibCompress+AceSerializer (v0)
(T:285-289, :290-331; custom base64 table T:42-92); errors are returned as strings ("Error decoding.", "Error deserializing", T:309, :334).
Payload envelope from `Private.DisplayToString` (T:340-379): `{ m = "d", d = <aura>, v = 1421 | 2000, s = versionString, c = {children} }`
(T:345-356, :371) — `v = 2000` when nested groups exist (T:347). `CompressDisplay` (T:114-141) strips unused custom-trigger fields
and `Private.non_transmissable_fields` (`Types.lua:3261`, v2000 variant :3274) and stamps `tocversion = WeakAuras.BuildInfo` (T:139).
Human-readable variant `Private.DataToString` (T:465-470).

**Addon-channel transport.** `Comm:RegisterComm("WeakAuras", HandleComm)` and `"WeakAurasProg"` (T:714-715); request `m="dR"` by
whisper (T:591-601), reply `TransmitDisplay` at `"BULK"` priority with progress echo (T:611-620), error `m="dE"` (T:603-609). Inbound
gate: only from senders we asked (`safeSenders`, T:592, :661) or holders of a chat link ≤ 5 min old (`linkValidityDuration = 60*5`,
T:650, :689; `Private.linked[id] = GetTime()` written by the options display button, `Options/AceGUI-Widgets/AceGUIWidget-
WeakAurasDisplayButton.lua:482`).

**Import path and validation.** `WeakAuras.Import(inData, target, callbackFunc, linkedAuras)` (T:518-588): accepts string or table;
requires `received.m == "d"` (T:530) and `type(data) == "table"` else `"Invalid import data."` (T:540-541); rebuilds parent/child
links for `v < 2000` (T:557-565); update-target uid checks (T:569-576); calls `WeakAuras.PreAdd(data)` on parent and every child
(T:579-583) **before** any UI; `ImportNow` → `Private.OpenUpdate` (T:498-516) deferring in combat (T:499-508). **No** check of
`d.id`, `d.regionType`, or `Private.regionTypes` in Transmission; unknown `regionType` later falls back to `"fallback"` with a print
(WA:3171-3173). **The future-version gate is disabled** — the block that would refuse `internalVersion > current` is commented out
under `-- Let people install auras that are newer` (T:544-555); the options UI shows a red label "It might not work correctly with your
version!" instead of hiding the import button (`Options/OptionsFrames/Update.lua:1395-1418` commented, :1562-1578 live), plus a
TOC-flavor mismatch warning (`Update.lua:1581-1590`). A "scam check" enumerates all custom code in the incoming aura and shows a
"view code" button (`Update.lua:66-133`, :1524-1533, :1591). UIDs are made unique at install (`EnsureUniqueUid`, `Update.lua:1691`;
`Private.ValidateUniqueDataIds` runs at login only, WA:1278, :2285-2309). Install writes bracketed by `Private.SetImporting(true/false)`
(`Update.lua:1678`, :1861), snapshotting history (`Update.lua:1875`).

**Schema versioning (`Modernize`).** `WeakAuras.PreAdd(data, snapshot)` (WA:2927-2969): legacy stubs → `pcall(Private.Modernize, data,
snapshot)` (WA:2936; error attributed "Modernize", WA:2938) → `Private.validate(data, regionTypes[rt].default)` → region-specific
`validate` → `Private.validate(data, Private.data_stub)` (`Types.lua:3284`) → subRegion defaults with an error print for unknown sub
types (WA:2941-2969). `Private.validate` fills defaults recursively and **replaces** a field whose type differs from the stub
(WA:406-417). `Private.Modernize(data, oldSnapshot)` (M:8-2228) is a flat ladder of ~70 `if data.internalVersion < N then` blocks from
2 to 86 (M:9, :2214); too-old data is warned and force-stamped to 2 rather than refused (M:10-11); a few branches are non-monotonic
(`== 49` M:1126; fork detection `== 67` and `> InternalVersion()` M:1317-1319; `< 67.1` M:1509; `< 83.25` M:2071); one step needs the
pre-migration snapshot (`ModernizeNeedsOldSnapshot`, `== 74`, M:2230-2238; snapshots via Archivist "migration" repo, `History.lua:65-74`);
final stamp `data.internalVersion = max(data.internalVersion or 0, WeakAuras.InternalVersion())` (M:2226) — a newer aura keeps its
higher number. `Private.Add` takes the migration snapshot only when `(data.internalVersion or 0) < internalVersion` (WA:3138-3144).
Login-time DB gate: `db.dbVersion < internalVersion` → migrate + snapshot; `> internalVersion` → refuse login and offer the repair popup
(`"downgrade"`, WA:1291-1308; `NeedToRepairDatabase` WA:2228-2230; `RepairDatabase` restores from snapshots WA:2232-2254). Archive
retention 730 days (WA:1273-1274; `History.lua:22-39`).

**REUSABLE MECHANISM**
- Version-prefixed string (`!WA:N!`) with a sniffing decoder that keeps every older codec alive (T:284-337).
- Serialize → deflate → print-safe encoding; separate encoder for the addon channel (T:255-282).
- Strip a declared "non-transmissable" field list and stamp the client build before export (T:114-141; `Types.lua:3261`).
- One entry (`PreAdd`) that runs the version ladder then default-fills and type-corrects against a stub, in `pcall`, before the
  data is trusted anywhere else (WA:2927-2969).
- Flat `if version < N` ladder with a final `max()` stamp; snapshot before migrating; login refuses when the DB is newer than the code
  and offers a repair (M:8-2228; WA:1291-1308).
- Inbound comm accepted only from solicited senders or recent link holders (T:650-661, :689).

**POSTURE NOT TO INHERIT**
- Importing arbitrary user-authored code strings from chat/wago and relying on a "scam check" viewer (`Update.lua:66-133`) — the
  entire trust model exists because payloads carry Lua.
- Disabled future-version gate (T:544-555) — a product decision to prefer "let people install" over refusing.
- Five serialization/compression libraries kept for backward compatibility of a decade of strings (T:201-205, :285-289).
- Version-mismatch fork branches (M:1317-1319, :1509) — history of a forked codebase, not a technique.

---

## 8. STAGE / SEQUENCE ANALOGUES — ordered stages, ratchets, "listen only to X"

WA has **no first-class stage/sequence primitive**. What exists, mechanism by mechanism:

- **Trigger combination + active-trigger selection.** `disjunctive = any | all | custom` over per-trigger booleans, and
  `activeTriggerMode = first_active | n` chooses whose state drives the display (WA:4608-4635, :4744-4753). Custom combination is a
  user function of the `triggers` boolean array (WA:4621-4631). This is a Boolean network over independent triggers, not an ordered
  machine — there is no notion of "trigger 2 only after trigger 1".
- **Trigger-observes-trigger (`TRIGGER:n` events).** A custom trigger may list `TRIGGER:2` as an event; then whenever trigger 2's
  state changes, the observer is run with event `"TRIGGER"` after the aura's own state machine has settled (GT:1829-1839 parse;
  producer GT:837-840 → `Private.AddToWatchedTriggerDelay`, WA:4684-4687; drained WA:4698-4709, :4816; observer scan GT:1049-1074).
  Guarded against mutual observation ("would cause a stack overflow", GT:1833). This is the closest thing to a data-flow edge between
  stages, and it is one-way and deferred.
- **Trigger State Updater (TSU) — arbitrary state machine in user Lua.** Custom triggers with `custom_type = "stateupdate"` receive
  `allstates` and events and return `true` if changed (GT:655-674 `statesParameter = "full"`); helpers `Update/Replace/Remove/RemoveAll/
  Get/IsChanged/SetChanged` (`TSUHelpers.lua:140-150`, mutators marking both state and table dirty :18-20, :84-86, :93-95). Any ratchet or
  ordered progression a user wants is written here; WA only supplies the dirty-flag contract and type validation
  (GT:668-674 wipes on non-table state).
- **Counters (event counting).** `countEvents` triggers keep a per-trigger `counter` object reset on load (`data.counter:Reset()`,
  GT:1481-1483; state field via generated code GT:437) — a monotone count, resettable, not a stage.
- **Duration/autohide ratchets.** State `autoHide` boolean-or-time and `expirationTime` drive a one-shot timer that flips `show=false`
  (WA:4520-4572); `paused`/`remaining` fields let a timer freeze (RP:936-948 `SetDurationInfo`; C:323-328 pause-aware remaining).
- **Dynamic groups: ordered children.** A dynamic group holds `sortedChildren` (DG:1195-1246), inserts on `ActivateChild` (called
  from the child's `Expand`, DG:1248-1269), removes on `DeactivateChild/RemoveChild` (DG:1271-1293), maintains order with an insertion
  pass in `SortUpdatedChildren` (DG:1297-1338; comparator from `createSortFunc`, DG:353; sorters table DG:278-351), positions via
  `createGrowFunc` (DG:997) in `DoPositionChildren` (DG:1519-…), optionally animated one frame later (`RegisterGroupForPositioning`,
  DG:1350-1351 → An:205-211). Ordering here is a **sort of currently-shown things** (by index/time/name/custom), recomputed on change,
  not a progression through predetermined stages. Batched behind `Suspend/Resume` (DG:1110-1143).
- **"Listen only to X".** Achieved by (i) load conditions (only armed auras have any listeners, §1), (ii) the event-keyed trigger index
  (only the exact event/subevent/unit reaches a trigger, §2), (iii) `RegisterEvent(event, unit)` + `frame.unit ~= unit` guards
  (GT:1503-1510, :1229), (iv) per-condition dynamic event subscription (C:941-1030), and (v) `Private.callbacks` (WA:50-66 —
  "worlds simplest callback system", 1:N, no de-registration) for internal lifecycle events (`ScanForLoads`, `Add`, `Delete`, `Rename`).
- **`Private.TimeMachine` is not runtime.** It is the options editor's undo/redo: transactions of data-path changes with
  `RegisterAction/RegisterEffect`, `StartTransaction/Append/Commit/Reject`, `StepForward/StepBackward` and a `SubscribableObject`
  notifying `"Step"` (`TimeMachine.lua:11-23`, :52, :72, :190-264, :305-337); gated behind the `"undo"` feature flag
  (`TimeMachine.lua:4-9`). It records edits, not game time.
- **`SubscribableObject`** (`SubscribableObject.lua:8-86`): `AddSubscriber(event, obj)` requires `obj[event]` to be a method
  (:23-26), `Notify(event, ...)` calls `subscriber[event](subscriber, ...)` (:71-77), `HasSubscribers` (:79-81),
  `SetOnSubscriptionStatusChanged(event, cb)` (:67-69) — the hook that lets a resource (the FrameTick OnUpdate) exist only while
  subscribed (RP:909-917). Used for region ↔ subregion events (`region.subRegionEvents`, RP:761; e.g. `Notify("Update"/"PreShow"/
  "PreHide"/"FrameTick"/"AlphaChanged")`, WA:4579, RP:1015, :1067, :662, :676), features (`Features.lua:91`), TimeMachine.

**REUSABLE MECHANISM**
- Subscriber-status callback that creates/destroys the underlying resource (`SetOnSubscriptionStatusChanged`, `SubscribableObject.lua:67`,
  RP:912-917) — the general form of "listen only while someone cares".
- Deferred one-way observation between state producers, drained after the machine settles (WA:4684-4709, :4816).
- Ordered-set maintenance by insertion pass over a dirty subset (`updatedChildren`), not full resort (DG:1297-1338).
- Dirty-flag contract for user/state producers with post-hoc type validation (GT:655-674; `TSUHelpers.lua`).
- Counter objects reset on arm (GT:1481-1483).

**POSTURE NOT TO INHERIT**
- Boolean trigger combination as the top-level model (WA:4608-4635) — a route is ordered, not conjunctive.
- Leaving progression logic to user Lua (TSU) — WA's product is a toolkit; a driver's stage machine should be code with a fixed shape.
- Sort-of-visible-things as "order" (DG) — the order a driver needs is authored, not derived from what is currently shown.
- Undo/redo TimeMachine — an editor concern.
