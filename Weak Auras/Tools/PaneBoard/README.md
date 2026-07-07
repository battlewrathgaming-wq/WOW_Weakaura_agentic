# Weak Auras Pane Board

An in-house spatial layout/intent board, standalone and owned entirely by
this project (WoW/WeakAuras) - not a shared tool, not gated behind any
other project's process.

## Where this came from

This is a duplicated, independent fork of Pane Board, a Lab-local tool
built inside a separate project called AURA-Lab
(`F:\Projects\AURA- Lab\src\...\labTooling\paneBoard\`). "Aura" is a
coincidental name collision between that project and WeakAuras - they are
unrelated, and this copy has no dependency on, and makes no changes to,
anything in AURA-Lab. Per Battlewrath (2026-07-10): "I own all of the
project work. And this work isn't falling into the workflow of Aura Lab."

The original is a real, working piece of software - not a prototype -
already used there as a human/agent spatial-conversation surface: panes
carry a grid position/size, a role, an importance, and an `intent` block
(anchor/relationship/notes) that reads almost exactly as "statements of
intent" - plus provenance (`source.createdBy: human|agent`) and a human
acceptance gate (`review.acceptedByHuman`). That shape is why it was
picked as the launch candidate for this project's own mask-editor idea
(see `../../AGENT_ROLES.md` and `../../ELEMENT_INVENTORY.md`'s pipeline
section for the underlying problem this is meant to eventually help
with: reasoning about/normalizing HUD slot positions and content).

## What was duplicated vs. trimmed vs. renamed

Copied verbatim (already fully generic, no AURA-Lab-specific logic):
- `src/modules/Frame/` - window chrome (pin/minimize/close), byte-for-byte
  copy of the original.
- `src/main/labTooling/paneBoard/paneBoard.js` - the board's real logic
  (read/write/normalize/snapshot/capture/PNG-export), copied whole.
- `src/renderer/pane-board/` - the actual board UI (drag/resize panes,
  editor fields, collaboration notes, board commands, capture/export
  actions), copied whole.

Trimmed: the original's `main.js` was one env-var-gated mode inside a much
larger presentation app, wired through a generic "service registry" IPC
bridge (`window.aura.listServices/invokeService`) that Pane Board's own
renderer never actually calls (confirmed by grepping for `window.` usage
before trimming). This standalone app's `src/main/main.js` and
`src/main/preload.js` are new, minimal files: Pane Board simply IS the
app, no mode toggle, no service registry.

Renamed: "Aura Lab" branding strings (window titles, the `project` field
each board/snapshot/capture stamps into its JSON) -> "Weak Auras" /
"Weak Auras Pane Board". The `AURA_LAB_PANE_BOARD`/
`AURA_LAB_PANE_BOARD_SMOKE` env-var mode gates were dropped (this app has
no other mode to gate against); the smoke-test env var was renamed to
`WA_PANE_BOARD_SMOKE`. Internal IPC channel names/window globals
(`aura:pane-board:*`, `window.auraPaneBoard`, `window.auraWindow`) were
deliberately left unchanged - they're just internal string constants with
no collision risk in a fully separate process, and renaming them would
have been pure churn.

## Local-meaning rewrite (2026-07-06)

The straight-duplication pass above is done; this pass wired in real
WeakAuras meaning per Battlewrath's follow-up ("adapting/re-writing to
reflect our local meaning... grid snapping to the 1PX, per element sizing
(1px from any dimension), and the kinds of fields we'd expect"):

**Grid unit is now 1, not 8.** 1 grid unit = 1 canvas px = 1 WeakAuras/WoW
UI unit - the same unit `x`/`y`/`width`/`height` already use in
`../Templates/schemas/*.schema.json` (those fields are typed `"number"`,
not `"integer"` - e.g. `buff_uptime_aurabar`'s `width` default is `127.5`)
and in the real shipped geometry in `../Tiers/resources_base.py`
(`CLASS_RESOURCE_POS` etc. use half-unit values like `-64.5`). A coarser
grid would have been an arbitrary tool convention unrelated to the real
values this board is meant to help author. Dragging/nudging snaps in
whole 1-unit steps; the schema-driven fields panel (below) still takes
exact decimal entry so half-unit legacy positions can be typed precisely.

On "ensuring the grid is the same WA and WoW uses": WoW's UI coordinate
space is normalized to a virtual screen 768 units tall (`UIScale = 768 /
screenHeight` at the "Pixel Perfect" setting; see Wowpedia/Warcraft Wiki's
"UI Scale" pages) rather than literal monitor pixels - but WeakAuras'
`xOffset`/`yOffset`/`width`/`height` fields are themselves expressed in
that same UI-unit space regardless of a player's actual scale setting, and
that's exactly the unit this project's schemas and `resources_base.py`
already use. Matching the tool's grid to that unit (1 unit = 1 schema
unit) is the correct target, independent of what a given screen's real
pixel count happens to be - there's no additional conversion factor to
apply on top.

**Minimum pane size is now 1 unit, not 4.** The real, already-shipped
`DIVIDER_POS` element in `resources_base.py` is only 3 units wide; a
4-unit floor made it unrepresentable in the tool.

**Fields are now opportunity-type-driven, not free text.** The old
`role`/`anchor`/`relationship` text inputs are gone. Each pane now has an
`opportunityType` (a dropdown sourced live from
`../Templates/schemas/*.schema.json` via a new
`aura:pane-board:list-opportunity-types` IPC call - the main process reads
those files at runtime rather than hand-maintaining a second copy) and a
`fields` object holding that schema's own properties (`name`, `spell_id`,
`x`, `y`, `width`, `height`, `show_when_missing`, etc.), rendered as real
inputs seeded from each property's schema default. `importance` and
`notes` are unchanged. Shared fragments with no `opportunity_type` of
their own (`load_conditions`, `glow_source`, `power_threshold_effect`,
`press_wash_effect`, `stack_counter_overlay`, `class_accent_tick_end`)
aren't offered as standalone pane types, since they compose onto a real
template rather than being one.

Still open: panes don't yet know about the mask (`../ELEMENT_INVENTORY.md`)
itself - there's no cross-check yet against what's already built/occupied
there. That's the next phase.

## Class-layout importer (2026-07-06)

One-way, read-only propagation of a board FROM a class's already-shipped
`inventory.py`, so the currently-known UI for a class doesn't have to be
manually redrawn pane-by-pane by hand (Battlewrath: "the ability to
propagate the board from the index... instead of having to manually
rebuild the current known UI per class by hand"). Deliberately kept as its
own separate stream rather than a live sync, for two reasons Battlewrath
raised directly: it must not impact the real build pipeline
(`build_templates.py`/`layer_builder.py`/`template_filler.py` are
untouched - this only ever reads), and imported content must not be
presented as equivalent to fresh prototype/sketch reasoning on the board.

Mechanism: `scripts/export_inventory.py` imports a class's `inventory.py`
via `importlib` (same approach `layer_builder.py` already uses to consume
it) and dumps every layer's slots to JSON - read-only, no writes, not part
of the real pipeline. `paneBoard.js`'s `importClassLayout()` converts each
slot into a pane (`opportunityType` = the slot's `template`, `fields` =
its `params` minus `x`/`y`, frame size from `fields.width`/`height` or the
schema default, position transformed from WeakAuras' center-anchored real
units into the canvas's top-left-origin ones) and writes a **brand new**
snapshot file under `workspace/pane-board/accepted-layouts/` - it never
touches whatever board is currently open, and never writes back to
`inventory.py`. The result is tagged `human-accepted` (this mirrors
already-decided, currently-shipped content, not a new sketch) with
`source.basedOn` recording exactly which `inventory.py` it came from.

One known approximation: a `dynamicgroup` layer's slots (e.g. "Minion
tracker") only carry local `x:0,y:0` in `inventory.py` - their real
position comes from WeakAuras' own runtime flow layout
(`group_layout.grow`/`space`), which this importer does not reimplement.
Those panes are placed near the group's anchor point in flow order and
their `notes` field says so explicitly - don't treat their exact
coordinates as authoritative the way a fixed-position slot's are.

Use it from the "Import class layout" panel in the sidebar: pick a class,
click Import snapshot. The imported file is written to disk but not opened -
use the snapshot loader immediately below to actually view it.

## Snapshot loader (2026-07-06)

Answers "how do I load it into view?" for the importer above (and for any
other snapshot under `human-sketches/`, `agent-proposals/`,
`accepted-layouts/`): a "Load snapshot into view" dropdown + button, right
under the importer, lists every snapshot file (title, status, and
`source.basedOn` if present) and swaps the **currently open board** for
whichever one is picked.

This is the one genuinely destructive step in the whole feature set (it
overwrites `current-board.json`), so it auto-backs-up the board you're
currently viewing first - the exact same `snapshotPaneBoard()` call the
"Grab state" button uses - before loading the new one, and reports the
backup's path in the message bar. Nothing is lost by switching boards.
`captures/` snapshots (a different shape, wrapping a board plus a
screenshot/kind/source) are deliberately excluded from this list; only
plain board files are loadable.

After importing a class layout, the new file is pre-selected in this
dropdown automatically, so the flow is: pick class -> Import snapshot ->
Load into view.

## Real-vs-modeled verification pipeline (2026-07-06)

Answers a different question than either feature above: not "how do I get
`inventory.py` content onto a board" or "how do I load a snapshot," but "I
hand-edited something live in-game - how do I check whether the board's
numbers (and this project's own modeled `resources_base.py`/`inventory.py`
values) still match reality, without a hand-edit silently becoming the new
source of truth?"

**Not the standard build loop - an occasional spot-check, run when there's
a specific reason to reconcile.** The normal path for building something
new stays schema/template -> `layer_builder.py` -> paste in-game (per
`AGENT_ROLES.md`/`BUILD_METHOD.md`), and normal iteration on something
already built is just live-editing it in WeakAuras directly - running this
pass on every single change would be strictly slower than just building
in-game (Battlewrath: "that's not the every time process... I may as well
just build in-game"). Reach for it specifically when a hand-edited test
case needs to be checked against what the base files currently model
before deciding whether/how to fold it back in - not as a ritual step
after every edit.

Mechanism, no new code involved - just a workflow across tools that already
exist:
1. Sketch or import the layout being discussed as a Pane Board board
   (freehand, or via the class-layout importer above).
2. Capture the real in-game aura as a WeakAuras export string - the
   group's own import string, not just one child, so the group's own
   frame position comes along too.
3. Decode it with `../weakaura_codec.py`'s `decode_group_import_string(s)`
   - returns `(group_table, children_tables)`. Read each child's
   `id`/`regionType`/`xOffset`/`yOffset`/`width`/`height` directly, and
   separately read the GROUP's OWN `xOffset`/`yOffset` - a whole-frame
   anchor offset that's easy to miss since it never shows up on any
   individual child, only on the group table itself.
4. Compare each value against the board's own `grid`/`fields`, and against
   whatever base file (`resources_base.py`, a class `inventory.py`) is
   supposed to be the source for that slot.
5. Log findings on the snapshot itself (`collaboration.notes.labs` for the
   technical trail, `collaboration.notes.human` for framing/decisions) -
   never write the real values back into the base files directly from this
   pass. That reconciliation is a separate, deliberate human step later,
   exactly like the class-layout importer's own one-way rule above.

Real run (2026-07-06, Reaper's "Resources_reaper" group, 8 children):
confirmed Cast Bar/Cast Bar Backing, Swing Timer/Swing Timer Backing,
Resources Divider, and Runic Power all matched `resources_base.py`'s
stored positions exactly - zero drift. Found two genuine differences worth
carrying forward: Soul Fragment had been resized/repositioned in-game
(from the full `CLASS_RESOURCE_POS` to a narrower, shifted footprint) to
make room for a brand-new "Reaped Soul tracker" icon with no existing
`inventory.py` entry at all; and the whole group's own frame carried a
`yOffset: -18` that none of `resources_base.py`'s numbers account for.
Also surfaced a recurring class of non-issue worth naming explicitly: two
elements' real `y` came back as `-152.2646795432088` instead of a clean
`-152.5` - sub-unit noise from dragging in the in-game options UI, not a
design change, expected to just round out whenever this gets formalized
rather than chased as a bug.

Three distinct outcomes a pass like this turns up, worth telling apart
before reacting to any one of them:
- **Exact match** - confirms a modeled value; nothing to do.
- **A real geometry/composition change** (resize, new element, restructure)
  - the actual reason to run this pass at all.
- **Precision noise** (sub-unit decimal drift from hand-dragging, or a
  whole-group anchor offset that's a placement choice rather than a
  per-element error) - worth recording so it isn't lost, but not something
  to "fix" element-by-element, and not a sign the importer or the board
  did anything wrong.

## Mask overlay / shadow slots (2026-07-06)

Answers a fourth question, distinct from the three features above: not
"what has this class already built" (the importer) or "how do I open a
saved board" (the snapshot loader) or "does a hand-edit still match the
model" (the verification pipeline), but "what is the WHOLE intended shape
of the UI meant to look like, including slots nothing has been built for
yet?" Battlewrath, 2026-07-06: "The ability to load the mask in, as purely
shadow slots. So not interactable, but define the whole UI. (And show the
gaps for what needs slotting.)"

`ELEMENT_INVENTORY.md` (project root) already documents every slot of the
`Template_shadow` scaffold - id, x/y/w/h, region type, and (for most rows)
an expected-function note - across its 8 row/tier tables, but by its own
words is "a markdown document, not code - nothing reads it
programmatically." A new script, `scripts/parse_element_inventory.py`,
is the first thing that does: it scans every `## Row X` section for table
rows whose x/y/w/h columns parse as numbers (this one heuristic
transparently skips header and separator rows without hand-matching each
table's exact 6- vs 7-column shape) and prints one JSON object
(`{"slots": [...]}`) to stdout - read-only, one-way, same architecture as
`export_inventory.py`'s class-layout importer above.

A "Show mask (shadow slots)" checkbox in the sidebar (off by default)
toggles a background layer on the canvas: every documented slot is drawn
as a dashed, non-interactive box (`pointer-events: none`, no drag
handlers, never added to `boardState.board.panes`) tagged either "filled"
(its footprint overlaps a real pane already on this board - simple
axis-aligned bounding-box overlap in grid-unit space) or "gap" (nothing
does yet, drawn with a warmer amber outline so it stands out). A status
line under the checkbox reports the total slot count and how many are
still gaps. Because the mask is never written into the board's own
`panes` array, toggling it, and the mask itself, has zero effect on what
gets saved, snapshotted, or captured - it's purely a reference layer for
seeing the whole intended shape at once, same one-way/read-only guarantee
as every other import path in this tool.

## Running it

```powershell
cd "Tools\PaneBoard"
npm install
npm start
```

State lives under `workspace/pane-board/` (created on first run):
`current-board.json` (the live working board), `human-sketches/`,
`agent-proposals/`, `accepted-layouts/` (snapshot destinations, chosen by
board status), `captures/` (resting records, optionally with a
screenshot), `screenshots/`, `materials/` (background reference images,
`.png` only, sandboxed to that folder).

`npm run smoke` runs the same automated round-trip check the original
had (save -> snapshot -> PNG export -> capture -> restore), via
`scripts/pane-board-smoke.ps1`.

Verified end-to-end on a real Windows machine via `install_and_start.bat`
(double-click in File Explorer - see that file's own comments): grid/zoom/
schema-driven fields all confirmed working live, including picking a real
opportunity type and watching the frame resize to match. The class-layout
importer and snapshot loader above have been verified at the data/syntax
layer (real `Necromancer`/`Reaper` inventory.py imports produce
correctly-positioned/sized panes, bad class names are rejected, all
touched files parse cleanly) but not yet re-confirmed visually in the
running app - do that before relying on an imported snapshot for real work:
import a class, confirm it's pre-selected in "Load snapshot into view",
load it, confirm the previous board was backed up and the imported layout
renders with correct per-opportunity-type frame sizes.
