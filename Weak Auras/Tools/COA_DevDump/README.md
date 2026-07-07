# COA_DevDump

A small custom addon (`COA_DevDump.toc` / `COA_DevDump.lua`) built to pull
real, live-client data into `SavedVariables` - since neither macros nor
`/devconsole` expose file I/O, this is the only way to get client-side
ground truth onto disk as text. Built 2026-07-04, first proven end-to-end
on the Necromancer (see `Outputs/live_reference/necromancer_live_reference.json`).

This doc exists so repeating the capture for another class/spec doesn't
require rediscovering everything the hard way a second time.

## Deploying it

The addon has to live in the actual game install to run - copy both files
into `<GameInstall>/Interface/AddOns/COA_DevDump/`, then enable it at
character select. The copy in this project folder
(`Weak Auras/Tools/COA_DevDump/`) is the source of truth; the game-install
copy is just a deployment target, always overwrite it wholesale rather than
hand-editing it in place.

## Commands

Type these in-game chat.

- **`/coadump trainer`** - open a class trainer NPC window first, then run
  this. Tries the plain, stock Blizzard trainer API
  (`GetNumTrainerServices`/`GetTrainerServiceInfo`/`GetTrainerServiceCost`/
  `GetTrainerServiceDescription`) and **it just works** - confirmed on
  Necromancer, 125/125 services captured cleanly with real names, gold
  costs, level requirements, and fully server-resolved description text
  (no `$s1`-style tokens - the server fills those in before sending).
  Trainers are server-driven by design in stock WotLK, so there's no
  client-side data for a custom class to need to bypass, unlike talents.
  Also runs a generic widget-field probe of `ClassTrainerFrame` as a
  fallback/cross-check in case some other class's trainer *does* override
  the stock system - check `numServicesStockAPI` in the capture; if it's 0,
  the fallback `widgetProbe` array is what to dig into instead. Results
  **accumulate** across calls (keyed by capture timestamp, appended to a
  list), so visiting multiple trainer NPCs across sessions is safe.
- **`/coadump talentnodes`** - the real talent extractor. Open the talent
  panel, have a spec tab visible, then run this. Walks
  `CoATalentFrameTreeViewSpecTree` and `CoATalentFrameTreeViewClassTree`
  and records every button carrying a real `spellID`/`rank`/`maxRank`
  field - **this server's custom talent UI does not use the stock
  Blizzard talent API at all**, confirmed via `GetNumTalentTabs()`
  returning 0 through both the bare call and the documented
  `(inspect, pet)` call shape. Results **accumulate by spellID**, so run
  it once per spec tab (and the Class tab) you have unlocked - the node
  pool only instantiates widgets for whatever tab is currently visible, so
  a single call only ever sees one tab's worth of nodes.
- **`/coadump talents`** - the stock-API attempt, kept only as a fast
  sanity check. Confirmed dead (0/0) on this server; would only be useful
  again if testing a different server/build where talents might actually
  go through the normal API.
- **`/coadump talentframe`** - generic, unfiltered recursive widget dump of
  the whole talent UI. This is what originally found the `spellID`/`rank`/
  `maxRank` field names in the first place. Only reach for this again if
  `talentnodes` ever comes up empty and the field names need
  rediscovering - it's slow, produces a much bigger file (~1.2MB for a
  single capture), and had one recursive helper (`FindChildText`/
  `FindChildTexture`) that was briefly suspected of causing a client crash
  before the timing (crash was at quit, not during the call) cleared it.
- **`/coadump frames`** - frame-stack snapshot at the current mouse
  position, same idea as the built-in `fstack` console command. General
  UI-debugging utility, not specific to this pipeline.
- **`/coadump probe <FrameName> [field1,field2,...]`** - generalized version
  of the `talentframe`/`trainer` widget-probe pattern: walks any frame that
  currently exists in `_G` (e.g. `TotemFrame`) recursively, reading a given
  comma-separated field list off every widget (or a sensible default list
  if omitted). Built 2026-07-06, motivated by the Witch Doctor totem-bar
  question - collapses what had been two copy-pasted one-off walkers
  (`talentframe`'s and `trainer`'s) into one reusable command, so the next
  time some other CoA-custom frame needs the same reconnaissance treatment
  it doesn't need its own bespoke `Dump<Thing>` function. **Important scope
  note confirmed while building this**: only useful for frames that stash
  data as plain Lua table fields the way CoA's own custom talent buttons
  do. Stock, API-backed frames (`TotemFrame` itself is the motivating
  example - confirmed a real `Cooldown` widget fed by `GetTotemInfo`, not a
  custom field) will only show structure through this command, same as
  `/coadump frames` already does - the actual data for those lives behind
  the API call, not on the widget. Results accumulate across calls, keyed
  by capture time + root frame name.
- **`/coadump clear`** - wipes all saved data.

After any capture, **`/reload`** flushes `COA_DevDumpDB` to disk at
`WTF/Account/<ACCOUNT>/SavedVariables/COA_DevDump.lua`.

## Known gotchas (all hit for real this session)

1. **The bash tool's view of this file can be stale, even right after a
   fresh `/reload`.** This is a different flavor of the FUSE mount-lag bug
   documented in `CLAUDE.md` - that one is about files *we've* edited
   multiple times; this is about a file an *external process* (the game
   client) rewrites. Confirmed directly: `wc -l`/`stat` via bash kept
   reporting the exact same size/mtime across two different real captures.
   **Fix: always use the `Read` or `Grep` tool to check this file, never
   bash.** Those reliably saw the current version both times this came up.
   If a capture "seems missing" after checking with bash, re-verify with
   Read/Grep before concluding the in-game command failed.
2. **The file gets big fast and exceeds `Read`'s single-shot size limit**
   (256KB) once `talentframe` or a large `trainer` capture is in there.
   Use `Grep` first to find the key's line number (e.g. `grep -n
   '"trainer"'`), then `Read` with `offset`/`limit` targeting that range.
3. **The talent-node pool only populates the currently-visible tab.**
   `GetChildren()` on the tree view genuinely only returns nodes for
   whatever spec/class tab is on screen at capture time - this isn't a bug
   to fix, it's how the pooled-widget UI works. Plan on one
   `/coadump talentnodes` call per tab.
4. **Trainer header rows return garbage cost/levelReq.** Confirmed live:
   a `serviceType == "header"` row (the tree-name divider, e.g.
   `"Death"`/`"Rime"`) can report `cost = 1816288370` - an uninitialized
   read, not a real value. Filter these rows out entirely rather than
   trying to interpret the number.
5. **A client crash on quit is not this addon's fault** (probably) - hit
   once, but the crash happened at the moment of exiting the game, not
   during any `/coadump` call, and a second identical `talentnodes`
   capture afterward ran clean with no crash at all. Timing alone rules
   out the addon as the direct cause. Still, always `/reload` *before*
   closing the client so anything captured is flushed regardless of what
   happens after.

## Turning a raw capture into a reference file

1. Find the SavedVariables file:
   `<GameInstall>/WTF/Account/<ACCOUNT>/SavedVariables/COA_DevDump.lua`.
2. `Grep` for the top-level key you want (`"trainer"`, `"talentNodes"`) to
   get its line number, then `Read` that range (chunk it if it's long).
3. Reproduce the raw Lua table literal **verbatim** (copy-paste the text
   you just read, don't retype/summarize it) into a small file wrapped as
   `return { ... }`.
4. Convert to JSON with a real Lua interpreter rather than hand-parsing -
   `lupa` (`pip install lupa --break-system-packages`) can `load()` and
   execute the chunk directly, returning real Lua tables you then walk
   into Python dicts/lists and `json.dump`. This guarantees byte-accurate
   fidelity instead of risking a transcription error on a 100+ entry dump.
5. Run `Scripts/build_live_reference.py <ClassName> <Input/<class>_talents.json>
   <trainer.json> <talentnodes.json> <output.json>` - merges both capture
   types into the final name-keyed schema (see that script's own docstring
   for the full design rationale on why it's name-keyed, not spellId-keyed).
6. Drop the output under `Outputs/live_reference/<class>_live_reference.json`,
   plus the two raw JSON files alongside it for traceability, and add
   pointer links in `Weak Auras/README.md` and `Display/README.md` (see
   either file's existing entry for the Necromancer file as the template).
