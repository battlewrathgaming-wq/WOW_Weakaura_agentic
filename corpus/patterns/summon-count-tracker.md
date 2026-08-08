# pattern: summon-count-tracker (the TTL-decay variant)

_status: **candidate primitive — LIVE-PROVEN 2026-08-08 in TWO configurations** (Animate: Zombie 525379/15s = the
POC; Clockwork Guardian 806760/12s = the Discord request that prompted it). Hand-built by Battlewrath from the
design card; closure **CLEAN +5 residue** through the reverse gear. Provenance:
`export_20260808_223428_01.txt` → `corpus/planning/out/Zombie_tracker.docket.json`._

## What it is

**One icon carrying one number: how many of a timed summon you currently have up.** The answer to
"can u make a WA that tracks how many X u have up?" for every proc-or-pressed summon with a finite TTL —
zombies, clockwork guardians, hounds, bone constructs, champions, traps.

**You never count and you never subtract.** WA's clone machinery does the bookkeeping: each summon event mints
its own state with its own TTL, and expiry retires it. A ten-line observer just reads how many states are live.

## The two fork facts that shape it (source-verified, 5.21.2/iv86)

1. **A trigger can OBSERVE another trigger** — `TRIGGER:<n>` is a valid custom-trigger event, and the observer's
   function is invoked as `(allstates, event, watchedTrigger, states)` where `states` is the watched trigger's
   FULL state table (`Private.ScanEventsWatchedTrigger`, GenericTrigger.lua:1049).
   **This is why no combat log gets parsed by hand:** the structured trigger catches (it knows this client's CLEU
   arg layout), the custom trigger only counts. Zero arg-position risk — the classic silent-failure hole.
2. **Bare `COMBAT_LOG_EVENT_UNFILTERED` is DISABLED in this fork** (GenericTrigger.lua:1908 — unfiltered CLEU
   "disabled as it's very performance costly"). Any *custom*-trigger CLEU route must use the filtered
   `CLEU:SPELL_SUMMON` form. The structured trigger below sidesteps this entirely.

## The signature (decoded verbatim from the closed docket)

- **trigger 1 — the catcher (never displays):** `type: combatlog` · `subeventPrefix: SPELL` +
  `subeventSuffix: _SUMMON` · `use_sourceUnit: true` + `sourceUnit: "player"` · `use_spellName: true` +
  **`spellName: ["<summon spell id>"]`** (stored-form note: the combat-log trigger's *Spell* field holds the ID
  under `spellName`, as a multiEntry ARRAY — not `spellId`) · **`use_cloneId: true`** ("Clone per Event") ·
  `duration: "<ttl seconds>"` (timed hide)
- **trigger 2 — the counter:** `type: custom` · `custom_type: stateupdate` · `events: "Trigger:1"`
  (case-insensitive; the parser uppercases) · `check: "event"`:

```lua
function(allstates, event, watchedTrigger, states)
    if event ~= "TRIGGER" or watchedTrigger ~= 1 then return false end
    local n = 0
    for _, s in pairs(states) do
        if s.show then n = n + 1 end
    end
    local state = allstates[""]
    if not state then state = {}; allstates[""] = state end
    state.show = n > 0
    state.changed = true
    state.stacks = n
    state.progressType = "static"
    return true
end
```

- **`activeTriggerMode: 2`** — dynamic information from trigger 2, so trigger 1's clones never spawn icons
  (this is what keeps it ONE icon instead of N). Required for activation: all triggers.
- **display:** icon · `cooldown: false` (see the count, not a timer) · subtext **`%s`** (stacks of the
  active trigger) · `displayIcon` set MANUALLY (see below).
- **residue carried by the hand-build** (+5, harmless BuffTrigger1-era leftovers): `names: []` ·
  `spellIds: []` · `debuffType: HELPFUL` · `unit: "player"`.

## The two parameters — and nothing else

**The Lua is universal and is never edited.** Only two UI values change per summon:
`spellName` (the summon spell ID) and `duration` (its TTL in seconds). That is what makes this
shareable as a BLANK: a recipient fills two boxes and never opens a code box
([[design-for-the-everyman]] — custom earns its place, then gets out of the way).

**Icon rider (live-caught):** summon spells never appear on an action bar, and the combat-log trigger's sheet
carries **`provides: null`** — its states hand WA no icon, so with dynamic info coming from the TSU there is
nothing to auto-resolve. The icon must be set manually. Cheapest instruction for a blank: *put the same spell ID
into Display → Icon* — WA resolves an ID typed there, so it is the same number already in trigger 1.

## The population split — say this on any blank you ship

The TTL-decay shape only works for **finite-duration** summons. From the DB sweep (2026-08-08), the naming is
almost a clean tell:

- **`Animate:` / traps / champions — FINITE, works:** Animate: Zombie 15s · Bone Construct 20s · Bone Wraith 15s ·
  Tomb King 15s · Plaguefather 15s · Rotling 20s · Frost Wyrm 30s · the Champions 20s · Witch Hunter's Daredevil
  and Kennel Master 15s · Death/Scourge Trap 60s · Shadow Trap 30s · Clockwork Guardian 12s.
- **`Raise:` — PERMANENT (`durationMs: -1`), does NOT work:** Ghoul · Lesser/Greater Skeletal Warrior · Gargoyle ·
  Abomination · Crypt Fiend · Banshee · Skeletal Mage/Rogue · Decaying Colossus. These never expire, so a
  TTL-decay count only ever climbs. They need the death-accurate registry, or the
  [minion-count-tracker](minion-count-tracker.md) route if they land a per-minion buff on the caster.

## The honest limit

**It counts by TTL, not by life.** A summon killed early stays counted until its timer runs out. For short-lived
proc summons (12–20s) the drift is usually below notice — measured against the cost, this is the right first
build. Death-accurate counting means the GUID registry: raw `CLEU:SPELL_SUMMON` + `CLEU:UNIT_DIED` keyed on
destGUID — the [guardian-health-tracker](guardian-health-tracker.md) skeleton, ~20 lines, and the one place the
CLEU arg layout has to be right.

## The primitive it wants to become

A contract row set: `select` = the class's **finite-duration** summon spells (directly derivable — the resolver's
`summon` verb + `durationMs > 0`, exactly the sweep above), `emit` = this two-trigger signature with the ID and
TTL substituted. Natural member of the **Self-tracker** family when that contract is pressed; also a strong
picker shelf item ("my summons — how many are up"), since the whole thing is two data fields over a fixed shape.

## Bench finding surfaced on the way through

**`displayIcon` is not on the display sheet** (stub flagged `unknown field - kept`). A manual-icon path is a real
icon-region field the harvest missed; it matters the moment the machine presses an aura whose icon can't
auto-resolve — which is exactly this pattern. Harvest boundary, recorded — see `creator/verification/findings.md`.
