# COA Pane Board

A spatial board for the `COA_DungeonRun` panes. **Its only job is to answer taste
questions the inventory cannot** — how big should this be, does it sit right, is there
too much air. You drag the real rectangles at real size; the numbers fall out.

★★★ **It is a tool, not a second inventory.** `addons/planning/dungeonrun_interface_inventory.md` is the
authority. Nothing here mirrors it, and it carries no `zone`, `kind`, `subjects` or
`job` — putting those in two places is two things that must agree with nothing noticing
when they stop.

His framing, which is the whole scope:

> *"Everything that pertains to spacial setting. We don't need to mirror the inventory.
> Just answer human taste questions with it. It's a tool."*

## Why it exists at all

The inventory's `numbers` slot was unusable:

> *"I can't really settle the numbers. Their abstractions on pixels that have no human
> relation."*

★ `154` is not something anyone can have an opinion about. A rectangle you can drag,
at the size it will really be, is. **Set the viewport to the pane's actual size and the
board is 1:1 with the client** — `grid.x/y/w/h` are exact client pixels.

## Running it

```
install_and_start.bat
```

First run installs Electron (~200MB, into `node_modules/`, gitignored). After that it
just starts.

## Where it came from, and what was cut

Copied from `Weak Auras/Tools/PaneBoard` — the aura bench's own fork of a tool built
originally inside AURA-Lab. ⚠ **A copy, not a shared instance**, the same call he made
for `geometry.py`: a module two benches must agree on is a fault at repo scale.

Removed, because all of it is WeakAuras:

| gone | why |
|---|---|
| Import class layout | Necromancer/Reaper `inventory.py` snapshots |
| Mask overlay | `ELEMENT_INVENTORY.md`'s slot mask |
| Opportunity type + its generated field editor | WA aura kinds |
| Board states | six workflow states down to two — sketch, accepted |
| `export_inventory.py`, `parse_element_inventory.py` | WA importers |

Changed:

- **Viewports are our panes**: Object 240×600, Promotion 320×400, Curation 240×330.
- **The namespace is `board:` / `paneBoard`**, not `aura:` / `auraPaneBoard`. ⚠ On this
  bench "aura" names a *different bench*, so the inherited name was actively misleading.

Kept, deliberately:

- **Materials / PNG backdrop.** Put a screenshot of the real pane behind the board and
  drag widgets onto it. That is the thing that gives a pixel a human relation.
- **Nudge pad, lock, zoom, snapshot, PNG export, board notes.** All spatial.

★ About 700 lines lighter than the copy it came from.

## The loop

1. Set the viewport to the pane you are working on.
2. Drop a screenshot of the live pane in as a material, if you want to trace it.
3. Drag until it looks right. Mark the board **accepted**.
4. The numbers go into `dungeonrun_interface_inventory.md`, which is the authority.
5. `layout.lua` derives every offset from the constants; the geometry check asserts it.

⚠ **Nothing reaches the client that is not in the inventory first.**
