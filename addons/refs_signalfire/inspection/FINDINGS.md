# Inspection pass 1 — what SignalFire IS (described in its own terms)

_2026-07-19. Data: `files.json` (per-file self-report) + `domains.json` (transport/events/
persistence/channels/time). Describe-don't-anchor: no proposal-join here._

## Identity & architecture

- **Built FOR this server family**: Interface 30300; toc Notes name Ascension/CoA + Triumvirate;
  a serverProfile system (`ascension/bronzebeard/coa/triumvirate`) selects behavior.
- **Two-era codebase**: `BronzeLFG.lua` (761KB monolith — 243 globals, 222 methods, 174 locals,
  143 frames, all 10 legacy slash commands) + eleven `SignalFire*` modules (newer, disciplined:
  methods hung on the `BronzeLFG` god-object + heavy `local` encapsulation, wrapped in
  `do repeat…until` blocks). Outward rebrand never reached persistence: SV is `BronzeLFG_DB`.

## The mechanism (the headline)

**It is a dual-source board system over chat transport — no SendAddonMessage anywhere:**

1. **SCRAPE feed**: parses HUMAN ads from public surfaces — `Global-Guild-Recruitment` channel,
   `global`, Say/Yell, plus `/who` sweeps (`WHO_LIST_UPDATE` → `whoGuilds`/`whoPlayers`) —
  `parserStats` tracks parser hit rates.
2. **MACHINE feed**: its OWN hidden channel **`BLFG`** (Network + Community subsystems) for
   addon-to-addon traffic.
3. **Boards cached in SV**: `guilds`/`guildBrowser*`/`publicGroups`/`myListing`/`favorites`/
   `network`/`signalFireNetwork` — background-populated listings, exactly board-shaped.
4. **Contact handoff**: prefilled WHISPERs ("Hi! I saw your SignalFire listing for …").

Events surface: CHAT_MSG_CHANNEL/SAY/YELL/SYSTEM · WHO_LIST_UPDATE · CLEU ·
PLAYER_TARGET_CHANGED · login pair. Time: C_Timer + OnUpdate throughout (cadences unmapped).

## Hacks ledger (seed rows — the fossil record)

| fossil | reading |
|---|---|
| SV named `BronzeLFG_DB` under the SignalFire brand | rename stopped at the persistence boundary (migration avoidance) |
| version-suffixed generations (`SF139_`, `SF573_`, `BLFG_5625_`…) kept alongside | patch history IN the namespace; old surfaces shimmed (`SF139_OldSlashBLFG`), not deleted |
| `do repeat … until` wrappers everywhere | hand-rolled early-exit (Lua 5.1 has no goto) |
| the "abandoned 1.4.34 badge" suppression (Core) | author narrates fighting their own legacy UI |
| per-subsystem channel constants (`SF139_DEFAULT_CHANNEL`, `SFE_CHANNEL`, `SFN_CHANNEL`) | channels accreted per era; two resolve to the same `BLFG` |

## Open for pass 2

- The `BLFG` wire format (payload builders near the CHANNEL send sites — encoded or delimited text?)
- Parser rules for the scrape feed (what makes a human ad parseable)
- Timer cadences (heartbeat? re-broadcast? poll loops)
- The profile system's per-server behavior switches
