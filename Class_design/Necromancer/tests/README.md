# tests — combat-log measurement

How we answer "does stat/mechanic X actually do Y" for a class: by
**measurement, not tooltip guesswork**. The method, proven here on Necromancer
(2026-07-27):

> **capture (`/combatlog`) → parse (a gear) → reason on the landing.**

Never hand-count raw log lines — build/point the gear and read its output.
Inventiveness lives in *building the tool* and *interpreting the result*, not in
the extraction. (These tools are class-agnostic; they live here for now and can
move to a shared home once a second class needs them.)

## Capture

`/combatlog` on → do the thing → `/combatlog` off. Writes
`<client>/Logs/<datetime> WoWCombatLog.txt` (ms-precision; datetime-stamped;
appends within a session). Use a **level-appropriate Dynamic Training Dummy** so
spells don't MISS (a higher-level dummy inflates miss chance — itself a "Hit
matters" signal). One ability at a time; the parser filters noise but a quiet
spot is cleaner. Two files = two conditions (e.g. no-haste vs +haste).

## Tools

- **`parse_combatlog.py`** — DoT / periodic ability. Per application: tick
  timeline (offset + interval), summons, self-heal, aura duration. (Harvest Plague.)
- **`crypt_analyze.py`** — channeled ability. Aggregates across casts: damage
  ticks + total, Runic Power energizes + total, channel durations. (Crypt Swarm.)

Both: `py <tool>.py "<log path>" --player <YourCharName> [--spell "<Name>"]`

## Format facts / gotchas (learned live)

- Line = `M/D HH:MM:SS.mmm` + **two spaces** + comma-CSV; first field = subevent.
  No year in the line (it's in the filename). Standard 3.3.5 CLEU field order
  (see `Weak Auras/COMBAT_LOG_CAPABILITIES.md`).
- **Match by spell NAME, not id.** Live cast ids differ from DBC ranks (Harvest
  Plague logs as `583255`, not the DBC `500968`/`501890`), and channel damage/RP
  fire under *triggered* ids (Crypt Swarm's `800343`/`800344`). A hardcoded-id
  filter silently matches nothing → a false "0".
- **Filter to your character** (source name) — logs are full of nearby players.
- **Timestamps are ms** — enough for tick count *and* interval; no in-game
  `GetTime()` capture needed.
- **Channels trail** — a few damage ticks land just past `AURA_REMOVED`, so
  aggregate across casts rather than bucket strictly by the aura window.

## Results so far

- `stamina-loop-test.md` — Stamina is a damage stat (pet-HP→SP loop), multiplicative on Life Force.
- `harvest-plague-haste-test.md` — haste does NOT speed Harvest Plague's ticks (3 witnesses).
- `crypt-swarm-haste-test.md` — haste adds no output to Crypt Swarm; channel ~2% longer.
