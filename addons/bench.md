# bench — the validation loop + the fact basis

## The loop (addons have NO headless canon — design work around this)

```
edit (repo copy) → deploy.py → client Interface/AddOns/ (game CLOSED - full restart loads it)
     → Battlewrath: /coadump r|st <task> → /reload flushes the mailbox
     → pull.py (watch) lands the record in landing/records/ → iterate
```

Mechanized 2026-07-15: `menu.bat` (the pinned bench terminal) hosts all of it. NOTE the
anti-cheat constraint: NEW/EDITED addon code cannot be loaded by /reload on this account —
full client restart. Design tasks to be installed once and steered by arguments/SavedVariables,
never by code edits between passes. /reload is still fine for flushing data.

- **The client is the only truth.** Offline you get syntax/logic only: `.tools/lua51/lua5.1.exe` (Lua 5.1.5 — the
  client's version; the wa_lua_verify precedent). Anything touching the game API needs the live half.
- **SavedVariables = the receipts channel** (COA_DevDump's model: dump to `COA_DevDumpDB`, flushed on /reload, read
  the WTF file back). Every capture tool should follow it: dump → flush → parse → land provenance-stamped output.
- **Battlewrath is the hands for the live half** — same as the aura bench. Request artifacts open with a use-case
  header (why + which IDs + reads/writes) so the reviewer sees the rationale before running anything.

## The fact basis (paths + anchors)

| what | where |
|---|---|
| live client AddOns (THE authority) | `F:\games\Ascension_wow\resources\ascension-live\Interface\AddOns\` |
| SavedVariables (the receipts) | `...\ascension-live\WTF\Account\BATTLEWRATH\SavedVariables\` |
| repo copy of the seed tool | `addons/COA_DevDump/` — v2: the task-registry capture spine (v1 campaign tool retired to git history 2026-07-15) |
| offline Lua | `.tools/lua51/lua5.1.exe` (5.1.5) |
| client version anchors | interface `30300` · WA fork toc `5.21.2` / `internalVersion 86` — establish per-addon anchors the same way |
| Ascension custom API | NO docs anywhere — source-grep the AddOns tree (`SpecializationUtil`, `ASCENSION_*` events, mysticenchant…); confirmed workable repeatedly |
| **`Data\Content\*.json`** (found 2026-07-15) | **LOOSE dev-authored custom game data, plain JSON, no MPQ needed**: `CharacterAdvancementData.json` (7MB, class→ability entries incl. ALL 21 COA classes under dev tokens + Reborn* stock, 44 Class values; Realms bitmask gates) · `SpellRankData.json` ({firstSpellId,level,rank,spellId} = THE rank-family table) · `SpellToSpellSuggestionData.json` (11MB relationship graph) · SkillCard/TradeSkill/Transmog/LFG…  Version anchor = the client build that ships them |
| `Data\area-52\listarchive` | one line: `patch-D.MPQ` — the realm folder's archive manifest (patch-D = the proven Spell.dbc source, 22MB) |
| 3.3.5 stock API docs | warcraft.wiki.gg (archived wowpedia) — SECONDARY: concepts freely, facts fork-confirmed |
| known client quirks | `debug.*` is STRIPPED server-side (no reflection); fileID icons risky on 3.3.5 (prefer paths/auto) |

## What the consumers expect (the inter-bench outputs)

- aura captures / import strings → `Weak Auras/ingest/inbox/` (paste_drop flow; the stub tool digests from there)
- data dumps / harvests → `Outputs/` or straight to a consumer-agreed home, provenance-stamped
  (`{source, captured, version-anchor}`) — see `corpus/README.md` for the envelope shape
