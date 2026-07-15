# backlog — the missions

_Ordered by leverage. Each is designed and waiting on exactly this bench._

## ★ THE FIRST GOAL (Battlewrath, 2026-07-15): the CLIENT-SURFACE CENSUS — probing / surface-finding

**Unique tables of every lever / API the custom client offers.** The wa_index move applied to the whole client:
read-the-authority once; every future question becomes a lookup. Two prongs:
1. **Runtime enumeration** (definitive for C-side API): a probe addon walks `_G` (globals, tables one level, frames),
   dumps via SavedVariables; the offline tool DIFFS against a stock 3.3.5 baseline (archived wowpedia API list = the
   subtraction mask) → **the delta IS Ascension's custom surface**. COA_DevDump's walker pattern, aimed at everything.
   Mind dump size: chunk the walk (globals A-M / N-Z etc.), flush per /reload.
2. **Source-grep corroboration** (offline, startable NOW): the AddOns tree + the client FrameXML (inside the Data
   MPQs — mpyq extraction proven by the Spell.dbc work) for `ASCENSION_*`, `RegisterEvent(`, custom namespaces →
   the EVENTS census (not runtime-enumerable) + a usage sighting per API row.
**Outputs** (`addons/maps/`, provenance-anchored to the client build): custom globals · custom events · custom
tables/namespaces · custom frames. **Standing consumers:** the spec capture (mission 1 = one table of this census),
the WA-env harvest (mission 3 = one slice), future aura triggers (the full custom-event list).

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
