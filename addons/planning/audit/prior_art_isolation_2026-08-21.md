# PRIOR ART — how WeakAuras and the profile addons ISOLATE at runtime (measured on the installed client)

_Design architect, 2026-08-21, at Battlewrath's direction (AL-10): "I would look at WeakAuras for
handling — many characters, many auras, many load conditions, many triggers/events — and other addons
that have profiles, where our profile is a route and it's whole." A read-only measurement by an
`Explore` agent against `F:\games\Ascension_wow\resources\ascension-live\Interface\AddOns\`; every line
cited; UNVERIFIED marked. **This file rules nothing.** What it gives the model is SHAPE, never code —
the mapping table at the foot is the deliverable; the citations above it are the proof._

**Sources measured:** WeakAuras 5.21.2 (`WeakAuras/WeakAuras.lua`, `GenericTrigger.lua` = GT,
`Prototypes.lua`) · AceDB-3.0 minor 20 (`Bartender4/libs/AceDB-3.0/AceDB-3.0.lua`; seven identical
copies installed) · profile consumers Skada · Omen · Bartender4 · ShadowedUnitFrames · Recount · PlateBuffs.
Prior repo measurements extended, not repeated: `audit/addon_weakauras.md` §1–§2 ·
`driver_neighbours.md` §1 · `history/data_model_findings.md` §4.

---

## 1 · WeakAuras LOAD CONDITIONS — eligible vs merely stored

Eligibility is a **compiled predicate plus a hash index; never tested per frame.** Three tables:
`loadFuncs[id]` (`WeakAuras.lua:287`) · `loadEvents[event][id]` (`:291`) · `loaded[id]` (`:297-298`).
Built at Add and **rebuilt whole by eviction**: the id is cleared from EVERY event bucket, then re-added
only to the ones it declares (`:3067-3075`) — no diff of old set against new.

The scan (`scanForLoadsImpl`, `:1529`): an event reaches only the auras that declared it
(`toCheck = loadEvents[event]`, `:1534`); O(1) miss (`:1553-1555`); world state gathered ONCE per scan
and handed to every predicate as one flat tuple (`:1557-1601` → `:1614-1615`); transitions only —
`toLoad` / `toUnload` (`:1617`, `:1626`); all work gated on a change count (`:1643-1647`). Re-scan
producers: 25 events on `loadFrame` (`:1689-1716`), four `UNIT_*` filtered to the player (`:1718-1735`),
the three `ZONE_CHANGED*` behind a world-map guard (`:1749-1772`), a delayed entering-world (`GT:1212`),
spec change (`GT:3983-3986`), and encounter start/end **only from DBM callbacks** (`GT:3990-4010`) —
WA registers no native `ENCOUNTER_START` anywhere (grep-verified). The load layer has **no OnUpdate**.

Unload (`Private.UnloadDisplays`, `:1877-1924`): custom onUnload → each trigger system's unload → wipe
trigger state → cancel every timer → unload conditions → collapse region and clones. Load resets the
header fields before the trigger systems see the aura (`:1854-1858`). **A stored-but-ineligible aura has
no region, no state, no timers, no conditions, no index entry.**

## 2 · TRIGGER REGISTRATION — only loaded auras receive events

`loaded_events[event][id][triggernum]` (`GT:1390-1399`), **CLEU one level deeper** by subevent
(`GT:1393-1395`), unit events in `loaded_unit_events[unit][event][id]` (`GT:1414-1416`). Dispatch is two
lookups and two early exits (`GT:885-901`) — nothing re-tested; the answer to "does this aura care" IS
the shape of the table. Unload nils the id out of every bucket (`GT:1248-1267`) — removal then
re-insertion, never a patch.

⚠ **The counter-example, re-verified:** `GenericTrigger.lua` contains **no `UnregisterEvent`** at all.
Game-event registration on the shared frame is additive-only (`GT:1274`); disarm removes the index
entry, never the listener, which then costs a hash miss per fire. The clean two-way edge exists
elsewhere — `SubscribableObject:SetOnSubscriptionStatusChanged` (FrameTick OnUpdate installed/removed)
and Omen's profile handler (`Omen.lua:648-659`, registers/unregisters per the new profile).

## 3 · PER-CHARACTER / MANY-AURAS STORAGE

**One wholesale table, no per-character split.** `WeakAuras.toc:22` declares only `WeakAurasSaved`;
loaded whole at `ADDON_LOADED` (`WeakAuras.lua:1257-1270`); every aura for every character lives in
`db.displays` keyed by `id` and is walked wholesale by `AddMany` (`:1194`). **A character is isolated
not by storage but by the load predicate** — `player · realm · class · race · faction · level ·
specialization` are load-prototype args in the same tuple (`Prototypes.lua:1075, :1126, :1132`;
`WeakAuras.lua:1614`). *The file is shared; the eligible subset is computed.*

Identity — two keys, neither the name-as-content: `id` is the store's own table key (structural
uniqueness; rename = key move `:2109-2111`; collision loop `:5832`) and `uid` is machine identity,
**regenerated on collision, never merged** (`ValidateUniqueDataIds`, `:2285-2310`; reverse index
`UIDtoID` `:2307-2309`). Mismatch guard: an `id` assigned to a different `uid` is refused (`:2984-2985`).
Nothing anywhere is matched by name similarity or record shape. (Carried, UNVERIFIED this pass:
`GenericTrigger.Rename` mis-copies CLEU subevent registrations, `GT:1299-1300`.)

## 4 · PROFILE ADDONS (AceDB-3.0) — one profile active, whole

`db.profile` **is** `db.sv.profiles[currentKey]` by reference — installed lazily by a metatable
(`AceDB:205-237` → `initSection` `:184-202`, `rawset` at `:199`); not a copy, not a view, not a merge.
Per-character part of the file is **one string**: `sv.profileKeys[charKey] = profileKey` (`:273-279`,
`:298`); profile bodies are account-global and shared. The switch (`SetProfile`, `:421-458`):
idempotent on the same name (`:427`) → `OnProfileShutdown` → **`self.profile = nil`** (`:440` — the
cached pointer DESTROYED) → selector moves (`:441`) → persisted (`:445-447`) → children follow → 
`OnProfileChanged` (`:457`). Nothing copies field-by-field; the next read re-seats. Logout strips
defaults back out so the file holds deltas only (`:350-379`).

Consumers on `OnProfileChanged` — all six bind Changed + Copied + Reset to ONE handler; five of six
**REBUILD** (Skada destroys windows, wipes, recreates from the new table — `Core.lua:3133-3157`; Omen
re-seats its upvalue and re-arms/un-arms listeners per the new profile — `Omen.lua:626-659`; Bartender4
`:144-166`; ShadowedUnitFrames `:382-400`; PlateBuffs `core.lua:264-267`); Recount PATCHES (`:1853`) and is
the outlier.

---

## 5 · SHAPE THAT TRANSFERS — the deliverable

| shape | WA / AceDB source | what it maps to in our model |
|---|---|---|
| Eligibility is an INDEX rebuilt on a state-change event, never tested per frame | `WeakAuras.lua:291 · :3070-3075 · :1534`; no OnUpdate in the load layer | the MANIFEST is built once at ARM from one RID; the tick reads it and never re-decides membership |
| The index is rebuilt by EVICTION, never diffed | `:3067-3069`; `GT:1248-1267` | re-arm = drop the whole manifest and build a new one; never merge or patch records into a live list |
| Dispatch = lookup with an O(1) miss; add a KEY LEVEL rather than a runtime test | `GT:885-898` | "is this record mine" is answered by PRESENCE in the table, never by comparison |
| One active selection = a POINTER to a whole table; switching DESTROYS the pointer | `AceDB:440 · :213-218` | the Active Route is a reference to one route's record set; ARM nils the old reference before seating the new |
| The switch is ONE event class, all causes collapsed | six consumers bind Changed+Copied+Reset to one handler | one `OnActiveRouteChanged` for arm / re-arm / reset — consumers need not know why |
| Consumers REBUILD on that event, never patch | Skada `Core.lua:3133-3157` | the tick list is destroyed and rebuilt from the new RID; nothing survives the swap by accident |
| The selection is persisted as a KEY, not data; idempotent | `AceDB:276-279 · :427` | the SV stores WHICH RID is armed — one field (AL-2's one slot); arming the armed RID is a no-op |
| Identity by UNIQUE KEY; collisions REGENERATE, never merge | `WeakAuras.lua:2294 · :2307-2309 · :2984-2985` | the RID is the address; lookalike routes are distinct because their RIDs are; a duplicate RID at load gets a new one (RI-4's re-mint, generalised) |
| The store's own table key gives structural uniqueness; rename = key move | `:2109-2111 · :5832` | routes live in `routes[RID]`; the display name is a field, never the lookup (§374's face/meta split) |
| A SHARED WHOLESALE STORE isolated by a COMPUTED SUBSET, not a split file | `WeakAuras.toc:22` + `Prototypes.lua:1126-1132` + `WeakAuras.lua:1614`; `AceDB:276-279` | ★ one routes file loaded whole is CORRECT and NORMAL — isolation is the ARM step selecting one RID, not a second file. This is the answer to Battlewrath's concern in AL-10 |
| Create at arm, tear down at disarm; ZERO footprint when unarmed | `WeakAuras.lua:1620 · :1877-1924` | no manifest, no listeners, no timers exist when no route is armed (A11.4's law, confirmed in the field) |
| Gather world state ONCE per scan; pass a flat tuple to every predicate | `:1557-1601 → :1614` | one position read per tick, handed to every record test |
| Gate all work on a CHANGE COUNT | `:1643-1647` | re-arm only when the RID actually changed |
| ⚠ TWO-WAY EDGE: disarm must UNREGISTER, not merely un-index | positive: `Omen.lua:648-659`, FrameTick; NEGATIVE: no `UnregisterEvent` in `GenericTrigger.lua` | DISARM unregisters every event the manifest registered — the WA counter-example is the thing to avoid (neighbours §5's one-way edge, measured again) |

**UNVERIFIED / bounded:** whether this client fires a native `ENCOUNTER_START` (WA does not listen for
one) · the GT Rename CLEU defect (carried) · submodules of Bartender4 / SUF for a cached `db.profile`
upvalue never re-seated · automatic profile switching (`LibDualSpec-1.0`) not audited · no AceDB profile
is scoped to a map or zone — selection is explicit or by the stored per-character key.
