# pattern: guardian-health-tracker (the GUID-registry TSU scaffold)

_status: **candidate scaffold — LIVE-PROVEN 2026-07-15 (four 527-hp guardian bars in-game), hand-built by
Battlewrath from the design card, shipped to a third party (Snackz/Discord) as a working handoff._
Provenance: `export_20260715_202335_01.txt` (corpus intake) → decoded `Pet health test` (dynamicgroup) +
`Pet health spawner` (aurabar). Evidence pair: `addons/landing/records/20260715_195725_117__plates.json`
(plates on → tokens + real HP) / `20260715_195846_424__plates.json` (creature rendered, plates unpopulated →
ZERO tokens). **The handoff itself is CLOSED (Snackz's project); the scaffold is ours to reuse.**_

## Closure (the house stamp, 2026-07-15)

**Both auras CLEAN** through the reverse gear (stub → press → registry-diff) — the scaffold's multiline TSU code
round-trips the full chain verbatim. Getting there fixed two gears: (1) the stub's first custom trigger exposed a
mis-strip (custom triggers aren't prototype-driven; the allowlist now comes from the contract's custom surface, and
the ledger-blindness lesson is on record: closure trusts the ledger, the GATE is the backstop for a wrong ledger
call); (2) findings #8 (the canon bridge's `%q`-as-JSON bug) was fixed to press this — regression clean across all
115 packs.

## What it is

**Tracks the health of units YOU summoned — and only yours — via nameplate tokens**, solving the ownership
hole the structured surface can't express: unit/Health's levers (name/npcId/hostility/…) have no "summoned
by me"; a `name` filter catches every same-named summon on screen. Ownership lives only in CLEU
(`SPELL_SUMMON`.sourceGUID), so this is a legitimate custom case ([[design-for-the-everyman]]: custom earns
its place exactly here — ten lines, isolated to the one inexpressible fact).

Mechanism: a **GUID registry** fed by CLEU (add on my `SPELL_SUMMON`, drop on `UNIT_DIED`) + a **resolver**
that maps registered GUIDs to whatever `nameplateN` tokens they hold right now → one static-progress state
per guardian (TSU auto-clones; the dynamicgroup stacks the bars).

## The hard boundary (live-demonstrated, both directions)

**The token's lifetime = PLATE POPULATION, not model visibility.** Creature fully rendered on screen with
plates unpopulated → zero tokens, `UnitHealth` unreadable (the evidence pair above). Bars honestly vanish
when a plate drops. Friendly-plate display is a hard runtime dependency. The only channel that survives the
gap is CLEU (GUID-keyed) — an off-plate HP *estimator* is possible (deltas), never a read.

## The signature (as-built, decoded verbatim from the drop)

- **group** (dynamicgroup) + **member** (aurabar) — display is fully structured; only the trigger is custom.
- **trigger** (member): Custom → **Trigger State Updater** (`custom_type: stateupdate`, `check: event`) —
  events box:

```
CLEU:SPELL_SUMMON CLEU:UNIT_DIED NAME_PLATE_UNIT_ADDED NAME_PLATE_UNIT_REMOVED UNIT_HEALTH:nameplate
```

```lua
function(allstates, event, ...)
    aura_env.guids = aura_env.guids or {}

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subevent, sourceGUID, _, _, destGUID = ...
        if subevent == "SPELL_SUMMON" and sourceGUID == UnitGUID("player") then
            aura_env.guids[destGUID] = true
        elseif subevent == "UNIT_DIED" and aura_env.guids[destGUID] then
            aura_env.guids[destGUID] = nil
        end
    end

    -- resolve my guardians to whatever plate tokens they hold right now
    local seen = {}
    for i = 1, 40 do
        local u = "nameplate" .. i
        local g = UnitGUID(u)
        if g and aura_env.guids[g] then
            seen[g] = true
            local s = allstates[g] or {}
            allstates[g] = s
            s.show = true
            s.changed = true
            s.unit = u
            s.name = UnitName(u)
            s.progressType = "static"
            s.value = UnitHealth(u)
            s.total = UnitHealthMax(u)
        end
    end
    -- plate dropped (or died) -> bar goes; the boundary, honestly displayed
    for g, s in pairs(allstates) do
        if not seen[g] and s.show then
            s.show = false
            s.changed = true
        end
    end
    return true
end
```

## Repeatable build steps

1. New Aura → **Progress Bar**; put it inside a **Dynamic Group** (clones stack per guardian).
2. Trigger → Type **Custom** → **Trigger State Updater** → Check On **Event(s)** → paste the events line.
3. Paste the code. Done — everything else stays default/structured (taste layer free).
4. Summon AFTER the aura loads (see limits). Bars appear while guardians hold plates.

## Source anchors (fork 5.21.2 / iv86, verified 2026-07-15)

- `CLEU:SUBEVENT` filtered registration: `GenericTrigger.lua:1800-1810`
- `UNIT_HEALTH:nameplate` group-expands to nameplate1..100: `GenericTrigger.lua:1331`
- CLEU arg layout (3.3.5: `timestamp, subevent, sourceGUID, sourceName, sourceFlags, destGUID, …`):
  `BuffTrigger2.lua:3606` (the engine's own reader)
- Plate tokens + `np._unit`: `C_NamePlateManager.lua:88` (patch-B extraction); dual-announce quirk
  (same GUID re-announced under `target`): GuardianPlates `Core.lua:115-129`
- Nameplate NOT in unit-trigger "Multi-target" (that's aura2-only, `Types.lua:1128`); Health's unit domain
  = `actual_unit_types_cast` (`Prototypes.lua:2337` → `Types.lua:1152`, includes `nameplate` + `member`)

## Known limits (POC-accepted; next layer if WE ever adopt it in-house)

- **No backfill:** summons predating aura load never enter the registry (re-summon, or seed at login via
  the name-free classifier from the plates record: `UnitPlayerControlled(u) and not UnitIsPlayer(u)`).
- **Hide-on-gap policy:** off-plate = bar gone (no CLEU-delta estimator).
- `UNIT_DIED` on a despawn-without-death (dismiss/timeout) may not fire — stale registry entries are
  harmless (never resolve) but unbounded across a long session.
- GUID entry-id note: creature GUIDs embed the NPC entry (`0xF130`+entry+spawn — Greater Skeletal
  Warrior=0xC779/51065, Abomination=0xC394/50068) → per-minion-TYPE filtering needs no names.

## The generalization

Every summoning class in the roster (Necromancer minions, Witch Doctor totems-adjacent, any guardian kit)
wants exactly this scaffold with a taste layer on top. The registry/resolver split also generalizes: the
registry is the OWNERSHIP primitive (CLEU-sourced), reusable by any "mine only" tracker regardless of what
the resolver reads (health today; casts/range/position tomorrow).
