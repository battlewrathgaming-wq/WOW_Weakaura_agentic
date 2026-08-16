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

## ★★★ The UI profile — capture everything, filter at the desk

> *"Can you make a stable test that captures everything? And then a reader to filter to the slice
> of interest. That way we have a profile as we develop."*

    /coadump r geom                      the capture — STABLE, it learns no new questions
    py addons/tools/read_profile.py      the reader — where the questions live

★★ **The split is the point.** `task_geom` takes everything cheap and readable in one pass —
geometry, state, alpha, text, colour, the declared kind and the live value — and every question
after that is a SLICE of the same record. ⚠ The project's own law pointed at its own probe:
*"the learner does not yet know what will matter, so filtering at capture decides for them before
they have had the run that would have taught them."*

    --surface promoter    one pane, every control
    --kind readout        by DECLARED kind, not by what the client calls it
    --colors              every tone in use and who wears it
    --text                every string the UI draws
    --unregistered        what nobody declared

★ **It reads the LANDED record, not the client** — provenance-stamped, comparable across captures,
and readable with the game closed. (`read_geom.py` still parses SavedVariables directly, because it
produces build constants and wants the freshest answer.)

⚠ **A capture from before §238 says so** rather than showing empty columns — an absent field and an
empty field are different answers, and a blank column reads as the second.

## ☛ The command reference — every in-game helper, at the bench

**Bench key `[H]`**, or `py addons/tools/emit_helpers.py [addon]`.

> *"Helpers, in-game, so /dr, produce a list. Each addon has them… I don't have them in memory.
> And I have no reference surface other than blindly trying in-game for the right command."*

⚠⚠ **THE COMMANDS ARE NOT UNDOCUMENTED — THE DOCUMENTATION IS IN THE WRONG PLACE.** It lives
inside the client, reachable only by already being in the client and already knowing what to
type. ★ **A reference you can read only from inside the thing it explains is not a reference.**

★★ **EXTRACTED, NEVER MAINTAINED.** A hand-written command list is a second copy that goes stale
the first time a branch is renamed — and it goes stale **silently**: the command still works, the
list still reads plausibly, and only the person typing finds out. This reads the dispatchers
themselves, so it cannot disagree with the client.

★ **What it prints is fact, not description.** The token, whether the branch consumes an argument,
and the first CALL the branch makes — `arm <arg> → Capture.Arm(rest)` says what it does in the
code's own words, and says it takes something, **which is the half a person actually forgets.**

    /coadump   COA_DevDump           r|run · st|start · sp|stop · mark · list · clear
    /dr        COA_DungeonRun        arm · pin · stop · map · edit · list · status · probe · ui …
    /coasp     COA_GuardianPlates    aggro · log on|off|toggle|status|dump|copy|clear
    /lm        COA_Landmarks         …and the rest, live from source

⚠ **Two bugs worth keeping, because both were silent.** The body scanner counted `end` against
`function` alone, so the DungeonRun handler truncated at its first `for … do … end` and `/dr ui`
reported one sub-command where it has six. And the call scan broke on a blank line, so **the
branches with the most reasoning written above them reported nothing at all** — the densest
comment gave the emptiest row, which is exactly backwards.
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
| **`Data\patch-B.MPQ` = THE client-code archive** (swept 2026-07-15) | ALL client-side UI code in one 6.8MB archive: 34 `Ascension_*` addons · modified `Blizzard_*` · FrameXML (378, incl. FrameXML.toc = declared load order) · GlueXML · SharedXML · **LibraryXML (157 — the retail-backport layer, CompactUnitFrame lives here)**. Extract via `addons/tools/extract_interface.py` → `Outputs/client_interface/patch-B/` (gitignored study copy; manifest.json carries the source sha256 anchor). First reads: **87 distinct `C_*` namespaces**, 60+ `ASCENSION_*` event strings. patch-A/I/X = art only; the 26 big archives = no Interface; 8 tiny ones unlistable (no listfile, bounded-opaque). The Cowork "mpyq can't" wall does NOT hold locally |
| client disk logs (found 2026-07-15) | `Logs\LUA.txt` = load-milestone log ONLY (Glue/FrameXML toc loads w/ timestamps — a useful /reload timeline). **Live-tested 2026-07-15: script/addon Lua errors do NOT reach it** — the error channel stays in-game (report what the dialog shows; an error-catcher hook is a possible future task). `Logs\Error.txt`/`Fatal.txt` = engine diagnostics, not addon-relevant. `Errors\*Crash.txt` = crash dumps (the 2026-07-04 17:43 one matches v1's "crash at quit") |
| 3.3.5 stock API docs | warcraft.wiki.gg (archived wowpedia) — SECONDARY: concepts freely, facts fork-confirmed |
| known client quirks | `debug.*` is STRIPPED server-side (no reflection); fileID icons risky on 3.3.5 (prefer paths/auto) |

## What the consumers expect (the inter-bench outputs)

- aura captures / import strings → `Weak Auras/ingest/inbox/` (paste_drop flow; the stub tool digests from there)
- data dumps / harvests → `Outputs/` or straight to a consumer-agreed home, provenance-stamped
  (`{source, captured, version-anchor}`) — see `corpus/README.md` for the envelope shape
