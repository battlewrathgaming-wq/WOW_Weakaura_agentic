# wa_lua_verify

Built 2026-07-06, in response to Battlewrath asking: "Is there not a way
to inspect how it [WeakAuras] handles it ahead of time? To push this to
its extreme - is there a way to emulate WA to see what it needs defining
and how?"

## What this is, and isn't

Full WeakAuras emulation (real combat state, `UnitCastingInfo`, actual
frame rendering) isn't attempted here - that would mean mocking the
entire WoW client API, a different and much larger undertaking. What
*is* narrower, self-contained, and genuinely reachable: WeakAuras' own
`default()` tables for each `SubRegionType` (`Tick.lua`, `SubText.lua`,
`Background.lua`, etc.) are pure data-definition functions with no game
API calls in them. This project's real, recurring bug class - shipping
a subRegion fragment that's missing fields the real addon expects,
discovered only after a live in-game test - lives entirely in that
narrow slice. So instead of hand-reading the source and manually
transcribing field lists (how `class_accent_tick_end` was built the
first time, and how it ended up missing 3 fields), this tool actually
**executes** the real, unmodified addon source under a real Lua 5.1.5
interpreter and extracts the true `default()` table mechanically.

## Why real Lua 5.1, specifically

The sandbox's first working prototype used `lupa` (an embedded Lua
runtime for Python) for convenience, but its bundled interpreter reports
itself as Lua 5.5 - a different, newer language version than WoW
3.3.5a's actual Lua 5.1. Battlewrath asked specifically for the
"correct" 5.1 so the tool's own interpretation can't silently diverge
from the client's. `setup.sh` builds real, official Lua 5.1.5 from
source (lua.org) - the same version WotLK 3.3.5a embeds - rather than
relying on a newer bundled runtime.

## Files

- **`setup.sh`** - downloads and compiles Lua 5.1.5 from official
  source. Re-run this at the start of any session that needs to use the
  harness - the sandbox is ephemeral, so the compiled binary doesn't
  persist between sessions. Takes a few seconds; no root needed (uses
  the `generic` make target specifically to avoid a `readline`
  dependency that can't be installed without root).
- **`harness.lua`** - stubs the minimal `WeakAuras`/`Private`/`L`
  globals a `SubRegionTypes/*.lua` file needs to load, captures every
  `WeakAuras.RegisterSubRegionType(...)` call made while loading it, and
  calls the captured `default` function (handling both plain-table
  defaults like `subbackground`'s and parentType-branching function
  defaults like `subtext`'s, trying `"aurabar"`/`"icon"`/no-argument
  variants and only collapsing to one entry if they actually agree).
  Prints the result as JSON. Deliberately permissive about anything it
  doesn't recognize (auto-vivifying stub tables, a catch-all `_G`
  metatable) - the only goal is reaching and calling `default()`
  correctly, not faithfully emulating unrelated game-API behavior.
- **`verify.py`** - the actual verification pass: runs the harness
  against every file in the real installed addon's `SubRegionTypes/`
  directory to build a ground-truth field set per subRegion type, then
  checks every subRegion instance in this project's own
  `Templates/templates/*.template.json` files against it, reporting any
  missing fields per file+instance (not just per type - a type being
  correct in one template doesn't mean every template using it is).

## Usage

```
bash setup.sh
python3 verify.py <path to Weak Auras/Templates/templates> \
                   <path to the installed addon's SubRegionTypes dir> \
                   /tmp/lua-5.1.5/src/lua \
                   harness.lua
```

## What it already found, first run (2026-07-06)

Two real, previously-undiscovered gaps, beyond the original
`class_accent_tick_end`/`threshold_value` bug this tool exists because
of:

- `resource_threshold_aurabar.template.json` (Mana/Runic Power's `%p`
  value readout) and `swing_timer_aurabar.template.json` (Swing Timer's
  `%p` timer) are both missing `text_automaticWidth`, `text_fixedWidth`,
  `text_wordWrap` - the same three fields `player_cast_aurabar`'s
  subtext entries already picked up when Battlewrath's real Cast Bar
  edit was synced in (fourteenth pass). That sync only touched Cast
  Bar's own template; these two siblings still have the older, smaller
  field set. **Still open, not yet fixed.**
- ~~`cooldown_tracker_icon.template.json`'s `subglow` fragment is
  missing `anchor_area`~~ - **resolved as a false positive (2026-07-06),
  not a real gap.** Once all 8 `SubRegionTypes/*.lua` files were run
  through the harness (see `../Templates/ICON_REGION_OPTIONS.md`), it
  became clear `subglow`'s `default(parentType)` only adds `anchor_area`
  for `"aurabar"` parents - the icon variant never has it, so an
  icon-parented template correctly omitting it isn't a gap. The original
  flag came from `verify.py` comparing every instance against one
  collapsed ground truth per subRegion type instead of per-parentType.
  `verify.py` itself isn't fixed yet to be parentType-aware (worth doing
  so this class of false positive doesn't recur for `subtexture`/
  `substopmotion`, which branch the same way) - but the finding itself
  is settled.

Remaining open item not fixed automatically - flagged for a decision
before touching any more real templates, per this project's working
agreement (`../CLAUDE.md`).

## Known limitation

The Lua 5.1.5 built here is official upstream Lua, not Blizzard's own
(slightly restricted/patched) client Lua - WoW's client removes/alters a
few standard library pieces (`io`, `os` are sandboxed, for instance).
None of that matters for this tool's actual use (loading a data-only
source file and calling a function that returns a plain table touches
none of those), but it's a real difference worth naming rather than
implying byte-for-byte client fidelity.
