# MancerLedger — long-term minion averages over Mancer's per-fight data

_Built 2026-07-31 in one arc (v0.1 → v0.6). The answer to the want that started the pet-parser
work: **we don't know what the game does under the hood, but we can infer through observable,
recordable events.** Serviceable for dummy testing as-is (Battlewrath's verdict, same day)._

## What it is

Mancer (LtGenZombie's Necromancer addon, internally `LibellusLeti`) parses every fight and
auto-saves the last 10 into its SavedVariables. It deliberately does NOT do lifetime
aggregation ("just a per fight thing" — the author). MancerLedger is that missing half, built
as a **read-only consumer**: it folds Mancer's saved fights into **profiles** the player
controls, so long-term averages accumulate per build/gear state instead of blurring across
them.

The relationship is by design, not accident: **Mancer is the driver, we are the consumer.**
Their parser is maintained by someone who mains the class; our value is the fold discipline,
the profile model, and honest presentation. See `DRIVER_CONTRACT.md` for every consumed field
characterized from their source — no invented use of their data ships without a license traced
there.

## The profile model (user-controlled, opt-in)

A profile = **name + character-state capture + accumulating log**.

- Created via the window (or `/mledger new <name>`): captures level / stam / int / spirit /
  shadow SP / AP / spell crit at that moment — the profile's identity anchor.
- Exactly one profile is **live** at a time; fights fold into it. Regear → make a new
  profile → compare. Recording can be OFF (fights wait in Mancer's 10-deep ring — nothing
  is lost until 10 newer fights push it out).
- **Nothing folds until the user creates a profile.** Opt-in is structural, not a setting.

## The fold (when and how data moves)

- Triggers: ~1.5s after leaving combat (letting Mancer's own commit land first) and at login.
  Lazy and lossless: Mancer's ring holds 10 fights, so even sparse harvesting drops nothing.
- Dedup: Mancer's own fight fingerprint (`startedAt:endedAt:damage`) is the fold cursor — a
  fight folds exactly once, into whoever was live at harvest time, surviving /reload,
  profile switches, and ring churn.
- Folded per minion type: damage, hits, misses + full missTypes breakdown, unit-time,
  summon count, fights-appeared-in, per-ability sub-buckets. All counters — every rate is
  derived at display time, nothing stored that should be computed.

## The surfaces

**The window** (`/mledger`, left-click the minimap token, or Interface Options → MancerLedger):
- **Profile dropdown** — the single selector; manage ops (Set Live / Rec Off / Rename /
  Reset / two-click Delete; name box feeds New and Rename) target it.
- **Stats** — the selected profile's per-type table.
- **Compare** — A/B dropdowns, then per-type **row triplets**: A's numbers, a signed delta
  row, B's numbers. Two **pages of the same data set, split by comparability class**:
  - *Rates* (default): attempts, cadence, miss% — "hold up across ordinary play - fight
    length doesn't skew them."
  - *Volume*: fights, summons, unit-time, hits, damage(raw) — "read best from controlled
    tests: same target, same army, similar fight lengths."
- **History** — a 50-deep timestamped event ring (folds, profile changes, warnings) in the
  window instead of chat dumping. Typed commands still echo answers to chat; UI clicks are
  silent; unsolicited chat never fires in combat.

**The minimap token** (the flight recorder): ambient recording state.
- **Red** = not recording (user's choice) · **Green** = recording · **Blue blink ~2s** = a
  fight just folded · **Amber** = LOCKED (wants to record, driver shape not understood).
- Left-click = window. Right-click = quick popout (profiles → make live; Recording Off).
  Draggable around the minimap ring; hover tooltip = live profile + fold count.

**Slash alias** (`/mledger ...`): `new/use/off/rename/list/stats/compare/resetlog/
delete <name> sure/harvest/status` — power-user lane; the window is the interface.

## Honesty machinery (the part that IS the product)

- **Cadence gate**: hits/unit-min renders only when `summons >= fights` (a temp minion
  summons at least once per fight it acts in). Kills the scope-mix artifact where a
  permanent's all-fight hits divide by one observed sliver window (live-caught: 174.9
  hits/min on a lone warrior).
- **Observed vs existence**: summons/unit-time are in-fight accounting; a permanent raised
  before the pull shows `-`, never a false 0.
- **Sample floor**: rates show `-` under 20 attempts.
- **Damage discipline**: raw labeled totals always; never a normalized family claim.
- **Comparability axes** (documented in DRIVER_CONTRACT): fight-length (the page split),
  target-defense (rates compare across similar content), population (some types' rates
  scale with pack size — Lesser Zombie; class-knowledge-curated, no mechanical detector).
- **Lockout on structural drift**: if the driver's data shape stops validating, ALL folding
  latches off — amber token, banner pinned in the window, zero chat. Auto-retries when
  either the driver's or our version changes; Harvest = manual retry. Additive drift
  (unknown new fields) just gets noted per profile with the introducing version.

## Files

- `core.lua` — driver access, fingerprint cursor, fold, profiles, lockout, history,
  slash + shared NS surface.
- `ui.lua` — the calm window (fixed chrome laid out once; refresh touches texts and pooled
  content rows only).
- `minimap.lua` — the flight-recorder token + popout.
- `DRIVER_CONTRACT.md` — the dependency characterization (read before touching the fold).
- SV: `MancerLedgerDB` = `{ profiles{}, active, seen[] (fingerprint FIFO, cap 60),
  history[] (cap 50), lockout?, minimap{angle}, uiPos }`.

## Status & held items

Proven: the naked/geared A/B (2026-07-31) — first scaling observation: pet miss% responds to
owner gear (−5/−6pp across types with sample). Held, designed, not built: **combatSeconds
fold** (fight durations pass through the fold and are currently discarded; accumulating them
promotes Volume columns to wild-honest per-minute rates — see DRIVER_CONTRACT comparability
section) · the **offer conversation** with the Mancer author (`addons/planning/
mancer_findings.md`) · duration-spread comparability hints in compare.

Offline smoke: `addons/tools/smoke/smoke_mledger.lua` — drives fold/dedup/lockout/window/
token against a fake MancerDB under lua51. Run it after ANY change here:
`.tools\lua51\lua5.1.exe addons\tools\smoke\smoke_mledger.lua`
