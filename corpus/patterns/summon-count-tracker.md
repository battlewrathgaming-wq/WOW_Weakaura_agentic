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
- **`Raise:` — PERMANENT (`durationMs: -1`), does NOT work here — use the OTHER pattern:** Ghoul ·
  Lesser/Greater Skeletal Warrior · Gargoyle · Abomination · Crypt Fiend · Banshee · Skeletal Mage/Rogue ·
  Decaying Colossus. These never expire, so a TTL-decay count only ever climbs.
  **Their authority is the buff-instance witness → [minion-count-tracker](minion-count-tracker.md).**
  Proven on the addons bench's raw CLEU record (`addons/COA_PetGrid/feed_live.lua` header, cross-bench
  reference 2026-08-08): *"Minion buffs are ONE INSTANCE PER INDIVIDUAL (3 ghouls = 3 auras) — the per-type
  instance count is the liveness AUTHORITY for Raise types"*, while *"Animates have no buff: TTL-governed."*
  So the two patterns are complementary halves of one problem, and each is correct for its half **because of
  what the game exposes**, not by preference.

## The honest limit

**It counts by TTL, not by life.** A summon killed early stays counted until its timer runs out. For short-lived
proc summons (12–20s) the drift is usually below notice — measured against the cost, this is the right first
build.

**And the obvious "fix" is a trap — CORRECTED 2026-08-08 by the addons bench's evidence.** The instinct is a GUID
registry (register on `SPELL_SUMMON`, drop on `UNIT_DIED`). On this fork that LEAKS: their raw record proves
**`UNIT_DIED` is SILENT for overwrite-despawn — 0 of 71** (`addons/COA_PetGrid/feed_live.lua` header; note their
own caveat that death-by-enemy was untested in that sample — a known sample bias, not a clean bill). A registry
keyed on UNIT_DIED would therefore hold ghosts for every replaced minion. Their conclusion, adopted here:
**liveness comes from the buff-instance witness + TTLs; `UNIT_DIED` is a BONUS path, never the authority.**
**REFINED 2026-08-08 (the hound log closes the caveat):** `UNIT_DIED` coverage is split by removal mode —
it **DOES fire for enemy-kills** (2 `Lesser Skeletal Warrior` deaths at flags 0x1111 = MINE|PET, killed by
Cursed Darkhounds) and is **silent for overwrite-despawn**. So for the TIMED population this pattern serves,
an optional upgrade is genuinely death-accurate: keep the TTL as the expiry path and add a `CLEU:UNIT_DIED`
drop for early deaths — the two together cover both exits. It is the PERMANENT `Raise:` family that a
registry still fails, because overwrite is their main exit and that is the silent one.

So: TTL (+ optional UNIT_DIED drop) for Animates — this pattern; buff instances for Raises — minion-count-tracker.

**The CLEU layout, if a raw-parsing variant is ever written** (independently confirmed twice — their parser
header and their captured landing record, `20260731_104452_749__petlog.lua`): classic 3.3.5 varargs, **no
`hideCaster`, no raid flags** — `1 ts · 2 subevent · 3 srcGUID · 4 srcName · 5 srcFlags · 6 dstGUID · 7 dstName ·
8 dstFlags · 9+ suffix (spellId, spellName, spellSchool)`. `UNIT_DIED` puts the dead unit at **dstGUID [6]** with
an all-zero source. The canonical `CombatLogGetCurrentEventInfo` is furniture on this fork — varargs is the real
channel ([[stored-field-isnt-live-check-consumption]]).

## Backlog seed — the death-accurate upgrade (DEFERRED, deliberately)

**Decision (Battlewrath, 2026-08-08): the TTL version is sufficient — ship it.** The error is bounded and
named: an over-count that **self-corrects within one TTL** (≤12s clockwork, ≤15–20s most Animates, 60s worst
case on traps). A "best guess" at that resolution suits the display's actual job — you read the count to decide
whether to re-summon, not to audit. This is an **ACCEPTED gap, not an open one**
([[trace-what-we-know-gaps-are-opportunity-or-accepted]]): revisit only if someone reports the drift bothering
them in play.

**A future session can start cold from here — the facts are already proven and cited:**

- **The design:** keep trigger 1 + its TTL as the *expiry* path, and add a `CLEU:UNIT_DIED` drop for *early
  deaths*. The two together cover both exits, because UNIT_DIED's coverage is split by removal mode
  (fires on enemy-kill, silent on overwrite — findings #18).
- **Already banked, no re-derivation needed:** the CLEU arg layout, confirmed empirically (findings #17) ·
  the UNIT_DIED split (#18) · `TRIGGER:<n>` observers as a composition primitive (#16) · bare
  `COMBAT_LOG_EVENT_UNFILTERED` is disabled, use the filtered form (above).
- **The real cost to weigh — it is NOT line count:** this pattern's shareable property is that *the Lua is
  universal and never edited*. A death-drop needs to match the dying GUID against the summons it registered,
  and **it is UNKNOWN whether trigger 1's clone states expose `destGUID`** for that matching (the combat-log
  sheet carries `provides: null`, so probably not). If they don't, the upgrade must catch `CLEU:SPELL_SUMMON`
  in raw Lua too — which puts the spell ID *into the code* and costs the two-boxes-no-code blank. **Check that
  first**; the answer decides whether the upgrade is cheap or whether it forks the pattern into two products.
- **Open unknown worth one test:** does TTL expiry itself emit `UNIT_DIED`? Presumed silent, untested. If it
  DOES, a registry alone suffices and the TTL becomes a fallback rather than the spine.
- **What it will never fix:** the permanent `Raise:` family. Overwrite-despawn is their main exit and it is
  silent — they stay with [minion-count-tracker](minion-count-tracker.md).

## The primitive it wants to become

A contract row set: `select` = the class's **finite-duration** summon spells (directly derivable — the resolver's
`summon` verb + `durationMs > 0`, exactly the sweep above), `emit` = this two-trigger signature with the ID and
TTL substituted. Natural member of the **Self-tracker** family when that contract is pressed; also a strong
picker shelf item ("my summons — how many are up"), since the whole thing is two data fields over a fixed shape.

## Bench finding surfaced on the way through

**`displayIcon` is not on the display sheet** (stub flagged `unknown field - kept`). A manual-icon path is a real
icon-region field the harvest missed; it matters the moment the machine presses an aura whose icon can't
auto-resolve — which is exactly this pattern. Harvest boundary, recorded — see `creator/verification/findings.md`.
