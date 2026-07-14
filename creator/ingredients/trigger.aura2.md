# trigger: aura2 — the buff/debuff window reader

_Reads the native aura window on a unit: is a buff/debuff there, whose, how long, how many stacks. The single biggest
reader in real-world authorship (buff-window = 66% of the corpus). Fact source: `sheets/trigger/aura2.json` (105 inputs)
filtered to LIVE keys (`maps/live_keys.json`: 77 live / 18 residue). Proven declare basis: the Target tracker + the tome._

## The proven core (start here)

```json
{ "type": "aura2", "event": "Aura",
  "declare": { "unit": "target", "debuffType": "HARMFUL", "ownOnly": true,
               "useName": true, "auranames": ["<spellId>"] } }
```
- `unit` — whose aura window to read. `player` = self-buffs/procs (91% of corpus use), `target` = your DoTs/banes.
- `debuffType` — `HELPFUL` (buff) / `HARMFUL` (debuff). Corpus: 87% HELPFUL.
- `useName` + `auranames` — **the family catch**: an ID in `auranames` resolves to the NAME (`BuffTrigger2.lua:2598`),
  catching every rank. THE drive-from-ID idiom. (`spellIds`/`names` are dead residue — the gate now blocks them.)
- `ownOnly` — only YOUR application counts. Good for: your DoT on a shared target, your proc not another's.

## CATCH — which auras match

| ingredient | what it does | good for |
|---|---|---|
| `useExactSpellId` + `auraspellids` | pins ONE exact spell id | one specific rank only — policy OFF by default (breaks on rank-up) |
| `use_debuffClass` + `debuffClass` | filter by dispel class (Magic/Curse/Disease/Poison) | dispel indicators, class-specific banes |
| `useIgnoreName` + `ignoreAuraNames` | exclude names from a broad catch | the over-catch fix when a name-family catches too much |
| `useNamePattern` + `namePattern_*` | fuzzy name match (contains/matches) | families that share wording, not IDs — last resort, prefer IDs |
| `use_castByPlayer` / `use_stealable` / `use_isBossDebuff` | provenance filters | boss-debuff trackers; purge/steal indicators |
| `useHostility` / `useClass` / `useActualSpec` / `useGroupRole` | who the WATCHED unit must be | group-unit triggers; rarely needed on player/target |

## SHOW — when it displays (the show-axis is separate from the catch)

| ingredient | what it does | good for |
|---|---|---|
| `use_matchesShowOn` + `matchesShowOn` | `showOnActive` (default) / `showOnMissing` / `showAlways` | **showOnMissing = the dropped-buff reminder** — ~45% of corpus buff auras fire when the buff is GONE ("you could cast this and haven't" — the bane/boon nudge) |
| `useStacks` + `stacks` + `stacksOperator` | show only at a stack threshold | payoff gates — corpus idiom: `>=` (at least N) |
| `useRem` + `rem` + `remOperator` | show by remaining time | about-to-expire warnings — corpus idiom: `<` (refresh window) |
| `showClones` | one display per match | multi-instance: several buffs from one catch, dynamic groups |
| `unitExists` | show even if the unit doesn't exist | rarely; default off is right for target trackers (no target → hidden) |
| `useGroup_count` / `useMatch_count` | count thresholds across units/matches | "N allies have my buff" — raid coverage displays |

## RESOLVE — when several match

| ingredient | what it does | good for |
|---|---|---|
| `use_combineMode` + `combineMode` | preferred match among ACTIVE matches | a runtime tiebreaker ONLY — it does not do rank resolution (corpus misuse: 0/319 needed it) |
| `combinePerUnit` / `use_perUnitMode` + `perUnitMode` | merge/split matches per unit | group displays; leave default for player/target |

## READ — what it provides (the composition material)

These are the state variables the trigger EXPOSES — for conditions (`check`), %text, and progress. Invention mostly
happens here: wiring provides → conditions → region changes.

| provides | good for |
|---|---|
| `stacks` / `totalStacks` | counters; trigger-2 threshold flips (the payoff pattern) |
| `matchCount` / `matchCountPerUnit` | **instance counting** — how many of THIS buff (each application its own instance): the minion-count pattern's engine (`%1.matchCountPerUnit` text) |
| `unitCount` / `maxUnitCount` | how many units matched (raid coverage) |
| `duration` / `expirationTime` | the timer; refresh-window warnings (pair with a `rem` condition) |
| `name` / `icon` / `spellId` | auto icon + %text — never hardcode what these provide |
| `unitCaster` | "mine vs theirs" displays beyond ownOnly |
| `debuffClass` | color-by-dispel-type |
| `affected` / `unaffected` (+`Units`) | who has / lacks it (fetch toggles) |
| `progressType` | what the bar/sweep shows — timed here |

_Every var above is also **text-addressable**: `%var` (own trigger) / `%<N>.var` (trigger N) in any subtext — plus the
four named tokens `%p` progress · `%t` total · `%n` name · `%i` icon (`Prototypes.lua:8875`). The full per-trigger
catalog = `maps/condition_vars.json`._

## Traps (learned live)

- A **stored** field isn't a **live** field — `spellIds`/`names`/`fullscan` etc. sit on real triggers and do nothing
  (converter residue). The gate blocks them now; the menu simply doesn't list them.
- One trigger = ONE active/show state; its condition-vars can read wider. A second *show* needs a second trigger;
  a second *reaction* needs a condition.
