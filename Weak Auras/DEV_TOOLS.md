# Client dev tools (found 2026-07-06, screenshotted by Battlewrath)

Two built-in tools this client exposes that neither this project's own DBC
extraction pipeline nor `db.ascension.gg` are - live, first-party ground
truth, no export/re-derive step in between. Worth using ahead of both for
any future verification, including tomorrow's live-validation queue
(`USE_CASE.md`'s "Open items" section).

## 1. "Show IDs in Tooltips" (Interface > Game > Help)

A checkbox in the stock Interface Options panel (`Interface > Help`,
alongside "Beginner Tooltips," "Display Lua Errors," "Show Zone Instance").
When enabled, tooltips show the item/spell's raw ID directly - hovering an
ability is enough, no external database lookup needed at all for the ID
itself. Confirmed enabled in Battlewrath's screenshot.

**Implication for this project:** the spell-ID curation gap flagged in
`DISCORD_POST.md`'s item 2 just got smaller - the *finding* half (what's
this ability's ID) is now trivially available in-client by hovering; only
the *organizing* half (which IDs matter for a given class's WeakAuras)
still takes real work.

## 2. `/devconsole`

An in-game Lua dev console (not a stock 3.3.5 client feature - custom to
this build). Full command list, transcribed from Battlewrath's screenshot:

| Command | Aliases | What it does |
|---|---|---|
| `memtables` | `tablemem`, `mtables` | Print estimated Lua table memory usage |
| `errors` | `showerrors` | Open the UI Error Window |
| `dfunc` | - | Hook a function to print the args used when it's called |
| `reloadui` | `rl` | Reloads the UI |
| `help` | - | Prints this command list |
| `cvar` | - | Get or set the value of a given cvar |
| `alias` | - | Create a function alias saved by the console |
| `etrace` | - | Show event trace window |
| `clear` | - | Clear the console |
| `event` | - | Listen for the event specified (`all` = every event) |
| `tfunc` | - | Hook a function to print the callstack, locals, and args when called |
| `tinspect` | `tdump`, `ti`, `tableinspector` | Open the Table Inspector |
| `dump` | - | Dumps the value following the command |
| `fstack` | - | Shows the frame stack |
| `listevent` | - | Lists all custom `C_Hook` UI events that are registered |
| `exit` | - | Close the console |
| `atlasbrowser` | `ab`, `av` | Open the Atlas Browser |
| `lookup` | `loo` | Search for something following the command |

**Implication for this project - this is a stronger verification method
than either existing source.** `dump`/`tinspect` can read a real Lua table
directly out of the live client - e.g. a spell's own table, or a unit's
actual power type - which is closer to ground truth than either
`necromancer_abilities_reference.html` (this session proved has at least
one real extraction bug - see `Necromancer/spell_index.md`'s Command-
abilities correction) or `db.ascension.gg` (accurate so far, but still a
second-hand community database, not the client's own data). Specifically
useful for:

- **Necromancer's power-type string** (`Necromancer/slot_assignment.md`'s
  open item) - `dump UnitPowerType("player")` (or similar) on a live
  Necromancer character would give a definitive answer, no need to
  reverse-engineer it through WeakAuras' own trigger-picker dropdown.
- **Any future spell-data question** - `tinspect`/`dump` on a spell's own
  table is a direct read, not a re-extraction through this project's own
  (occasionally buggy) pipeline.

**Not yet used for real verification work** - found and documented same
day discovered, not yet exercised against any of this project's specific
open items.

**Update (2026-07-06): the power-type question got resolved a simpler way
before `/devconsole` was needed.** Battlewrath captured real "Mana"/"Runic
power" WeakAuras in-game and pasted their import strings directly -
decoding them with this project's own `weakaura_codec.py` read the real
`powertype` values (0, 6) straight out of the aura's own trigger config,
no dev console required. Both tools remain worth knowing for anything a
WeakAura's own export can't show directly (e.g. reading a unit's state
outside of any trigger), but "capture and decode a real aura" is often the
more direct path when the question is specifically about what WeakAuras
itself sees.

## 3. `wa_lua_verify/` - project-side, not a client feature

Different category from the two above (those are IN the client;
this runs on our side, against the real addon source files this
project already has read access to). Added 2026-07-06, after
Battlewrath asked whether WeakAuras' own behavior could be inspected
ahead of time instead of discovered only after a live-test surfaces a
gap - directly motivated by the subtick field-parity bug (a fragment
missing 3 real default fields, only caught once an in-game import came
out wrong). Builds real Lua 5.1.5 from official source (matching WoW
3.3.5a's actual Lua version, not a newer bundled one) and executes the
real, unmodified `SubRegionTypes/*.lua` files under it, extracting their
genuine `default()` tables directly rather than hand-transcribing them
from a source read. `verify.py` then diffs every subRegion instance in
this project's own templates against that ground truth. First real run
already found two new gaps (see its own `README.md`) beyond the one it
was built because of. **Guardrail, per `CLAUDE.md`: this tool's own
result is a fast pre-check, not a substitute for a real in-game export**
- use it to catch things before a live test, but validate against a
real export when a finding is genuinely uncertain, not as a ritual on
every trivial change.

## 4. `layer_builder.py` - the shared, class-agnostic layer compiler

Added 2026-07-06, per Battlewrath's ask: rather than writing a one-off
Python script every time a tier gets built (13 sessions' worth for
Resources alone), each class gets one `<Class>/inventory.py` - plain
constants only (coordinates, options, spell IDs), organized as a
`LAYERS` dict keyed by layer name. `layer_builder.py` (project root,
not per-class) is the one function that turns any single named layer
into a real, auto-versioned import string (`<slug>_vN_import.txt`,
matching the existing `Resources_vN`/`Tier1_Rotation_vN` convention).
Builds exactly one layer per call, never the whole class UI - full
assembly of multiple layers still happens live, in WeakAuras' own UI
(BUILD_METHOD.md's existing per-tier/in-game-consolidation principle,
now with a formal tool behind the per-layer half of it instead of ad-hoc
scripts). Not to be confused with `Templates/build_templates.py` (that
one generates the schema/template JSON pairs this consumes via
`template_filler.py` - a different layer of the same overall pipeline).
First real consumer: `Necromancer/inventory.py`'s "Tier 1 Rotation"
layer - round-trip tested against the already-built
`Tier1_Rotation_v1_import.txt`, correctly auto-versions to v2 from the
declarative data alone.

## 5. `fuse_check.py` - drift detector for the sandbox's own FUSE mount-lag bug

Added 2026-07-06, per Battlewrath's ask ("Anything you can do to resolve
that fuse mount lag issue? Maybe having a batch file to run and check in
on?"). This is a recurring, sandbox-side bug distinct from anything in
WeakAuras itself: the agent's bash-mounted view of a file has repeatedly
been observed serving stale or truncated bytes for files edited multiple
times in one session (via the Read/Edit/Write tools), even though those
tools' own view is correct and current. `Templates/build_templates.py`
has been the worst-hit file - stuck mid-string on a version that
predates this session's edits, even though the real, tool-confirmed
content is correct and current, and even though its own generated JSON
outputs (in `Templates/schemas/`, `Templates/templates/`) were
separately re-verified correct.

**Honest scope: this is a detector, not an automatic fixer.** It can't
independently know which view (bash's or the tools') is right - it has
no access to the tools' side. What it does: report a fast, cheap
snapshot (line count/size/sha256/mtime) of what bash currently sees, so
drift gets caught in one quick call right after an edit, instead of
discovered mid-task via a confusing traceback. Usage:
```
python3 fuse_check.py <file1> [file2 ...]     # check specific files
python3 fuse_check.py --scan --save           # snapshot everything, save baseline
python3 fuse_check.py --scan --diff           # compare against saved baseline
```
When it flags a mismatch (or a file just won't parse/import), the actual
fix remains what this project already established: rewrite the file
directly via a bash heredoc (`cat > path << 'EOF' ... EOF`) using the
content already confirmed via the Read tool - that has been the one
reliable fix found so far. Used this same session to catch and correct
drift on `template_filler.py` and `layer_builder.py` before it could
cause a repeat of the confusing mid-task failures this bug has already
caused (see `Templates/build_templates.py`'s own still-unresolved case,
left as a known, flagged, non-blocking issue since its actual JSON
outputs are independently confirmed correct).

## Cross-references

- `USE_CASE.md`'s "Live validation queue" open item - update to use these
  tools as the actual verification method, not just WeakAuras' own UI.
- `Necromancer/slot_assignment.md`'s power-type-string open item.
- `Necromancer/BUILD_METHOD.md`'s "Layer numbering + inventory.py" section
  - the full architecture rationale for tool 4 above.
- `CLAUDE.md` - worth adding fuse_check.py's existence to the working
  agreement itself, since the underlying bug affects any file, not just
  the WeakAuras-specific tooling.
- `DISCORD_POST.md` - both client tools are themselves worth community
  documentation (not everyone doing WeakAuras work on this server
  necessarily knows either exists).
