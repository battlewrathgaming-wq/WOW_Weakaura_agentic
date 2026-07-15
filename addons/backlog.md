# backlog — the missions (three banked; each unblocks the aura bench)

_Ordered by leverage. Each is small, designed, and waiting on exactly this bench._

## 1. The spec-name capture (unblocks `load.specialization` for EVERY pack)

The load's `specialization` is an index-keyed multiselect (fork `Prototypes.lua:1075`, `IsSpecActive(i)`, domain
built live per class via `SpecializationUtil`). We need **index → spec-name per class** (a 20-entry list was observed).
Two routes: read WA's own Load-tab dropdown (it renders `"i. Name"` — the exact stored keys), or a dump tool calling
the SpecializationUtil API directly (mind: a naive one-liner returned `nil nil, true` — the return signature needs
source-checking first). Capture per class character. Output → a map (`spec_index.json`-shaped, per class, anchored).

## 2. The tooltip gap-fill micro-scan (~13 spells; designed 2026-07-12, parked)

The description holes the scrape couldn't carry: ~13 custom-class spells with raw `$`-variables or NULL text (the
Necromancer minion-command set etc.). `GameTooltip:SetSpellByID(id)` → read `GameTooltipTextLeftN:GetText()` → dump →
merge into the ability text. Bounded read-only ID list; the render is the ARBITER (accept-empty only on the game's
verdict). COA_DevDump extension — the design is in the memory/warm-start trail.

## 3. The WA-env harvest (the scripting lane's chartered first step)

For `creator/ingredients/custom.md`: harvest the aura-script sandbox surface — the allowed API (inverse of
`AuraEnvironment.lua`'s `blockedFunctions`/`blockedTables`) + the TSU state contract. Method: source-scan first
(the live_keys pattern); a dump addon only for what's runtime-built. Output → a map the palette cites.

## Standing / emergent

- **COA_DevDump hygiene**: it's the seed tool — adopt it into this bench deliberately (repo copy is the dev copy;
  deploy step to the client; version anchor in its .toc).
- **The existing root material** (`Mob_Autogroup/`, `Addon refs_threat/`): assess → adopt-by-rebuilding or archive.
  Not precious.
- **Whatever the aura bench's walls need next**: combatlog subevent keys (a GenericTrigger code-scan), the
  per-region animation-capability harvest — addon-side captures may serve where source-scans stall.
