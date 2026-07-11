# DATA_ROUTES — a flight record of how we route through the data

A running, deliberately-light log of the **traversal paths** from a question to what the
data can answer — and, just as importantly, **where each route stops.** This is the
operational form of `[[trace-what-we-know-gaps-are-opportunity-or-accepted]]`: every route
names its boundary, so a "we can't answer that" is always a *classified* edge (opportunity
to gather, or accepted unknown), never a shrug.

Add a row when a new route is found or a boundary is learned the hard way. Keep it terse.

## Routes (from → via → reaches | STOPS AT)

| # | route | via (field / source) | reaches | STOPS AT |
|---|---|---|---|---|
| 1 | ability → tooltip text | trainer/talent scrape → `ability_inventory/out/*.json` `description` | player-facing wording: Command/AoE, costs, ranks, flavour | describes **summon + Command only**, never the auto-attack; spellbook-only captures have `description: null` |
| 2 | spell → static profile | `dependencies/coa_spells.json` manifest | cooldown (`=max(Recovery,Category)`), castTime, duration, range, power cost, school, mechanic | player-cast spell statics only; cooldown validated 99.97% vs live |
| 3 | spell → proc / trigger chain | `effectTriggerSpell` (BFS closure, depth≤3) | triggered spells & proc buffs (e.g. Blizzard 10 → 42208; Bone King → 707176) | only **spell-driven** triggers; depth-limited; not creature-driven procs |
| 4 | summon → **creature id** | `effect == 28` (SUMMON) + `effectMisc[0]` | **which creature** a `Raise:` spawns (Crypt Fiend 504859 → creature **50323**; Skeletal Mage 500331) | STOPS at the creature — its attack/cleave/AA behaviour is in **server `creature_template` + creature spell list**, not our data. The id is the **doorway** to that gap. |
| 5 | talent → ability linkage | `SpellClassSet` × `SpellClassMask` / `EffectSpellClassMask` | which talents modify/enable which abilities (the content→behaviour bridge) | mask-based, needs decoding; see `[[proc-basis-plan]]` |
| 6 | behaviour → **observation only** | in-game test / community report | does a minion's **auto-attack** cleave? uptime? actual targeting | **not in tooltip, not in DBC.** Per-creature — there is **no default** (cleave *or* single-target, depends on the creature). Always a **verify**-unknown → dummy test / creature table via route 4. |
| 7 | spell → **what it DOES** (meaning) | `effect`/`effectAura` codes resolved via `Scripts/spell_enums.py` (SpellEffect 0..164 + AuraType 0..316, sourced verbatim) | the behavioural primitive: DoT, HoT, summon, proc, modifier, CC, direct damage/heal — and it cross-checks against tooltip verbs (they agree) | **Ascension-custom** codes (`effect>164`, `aura>316`: ~360+254 spells) resolve to `CUSTOM_*` — route-6. Also `dummy` (≈587) = server-scripted, opaque by design. |

## Behaviour log (route 6 — facts that live only outside the data)

Observation-sourced truths our data structurally can't see. Each is a filled accepted-unknown;
the eventual verification hook is the creature id (route 4) or an in-game meter test.

- **Skeletal Mage** (Rime, `Raise: Skeletal Mage` 500331) — **auto-attack IS AoE** (multi-target),
  not just the Command. Source: BoTFranK (Necro), dummies + dungeons, 2026-07-11. Data said "unknown,
  probably single-target" — the *probably* was wrong; the *unknown* flag was right.
- **Crypt Fiend** (`Raise: Crypt Fiend` 504859 → creature 50323) — **cleaves.** Source: Battlewrath,
  2026-07-11. No tooltip in our data at all; pure behaviour fact.
- **Rule learned:** minion AA cleave-vs-single-target has **no default** — it is a per-creature property.
  Never infer it from engine convention; observe it, or resolve creature 50323-style data.

## How this is meant to be used

Before answering a data question, pick the route(s); state what it reaches and name the stop.
If the stop matters, classify it: **opportunity** (route has a doorway to go gather — e.g. route 4's
creature id) or **accepted unknown** (route 6 with no cheap resolution but an in-game test). The
answer's value is the traced spine + the named edge, not a verdict on everything.
