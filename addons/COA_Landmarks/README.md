# COA Landmarks

**A self-authored scrapbook of places on the world map.** Mark somewhere that matters to you,
write why, and get back to it later.

*"How I play, not what exists."* It is **not** a gathering database, a quest helper, a travel
aid or a routing tool — pfQuest and GatherMate already answer *what exists*, with far bigger
records than this will ever hold.

**Spec: `addons/planning/landmark_design.md`** — every behaviour in the code cites its
criterion. **If code and brief disagree, the brief is right and the code is a bug.**
Fact basis: `addons/planning/satnav_ledger.md` (19 laws, F1–F42, four probe runs).

---

## What it restores — three things, and the fourth is not ours

| Lost | Instrument |
|---|---|
| **meaning** — why this place matters | the note, pulled on hover |
| **exactly where** | the in-game beacon, inside ~1,500 yd |
| **which zone, roughly where** | the world-map pin, and the widget's `Zone` line |
| ~~how to travel there~~ | **not ours — players already know** |

## Using it

**Mark where you stand** — three ways, none privileged, and none of them ask you anything:

```
/lm here                    (macro-safe, works in combat)
```
…or the widget's `make marker`, or **right-click the minimap button**.

**The widget** — `/lm`, or left-click the minimap button:

```
Landmark name          <- click to rename
Zone            [Map]  <- red, only when the beacon cannot guide
[repin] [clear]
[make marker]
```

**The world map** — hover a pin for the note · **click to go** · **right-click to edit**.

**The editor** — name, `What:` (a line), `Why:` (a page), `Beacon hide`, `Tags`, and
`Visible to`.

### Commands

| | |
|---|---|
| `/lm` | show or hide the widget |
| `/lm here` | mark where you are standing |
| `/lm list` | list what this character can see |
| `/lm all` | **recovery view** — show every character's landmarks. Off at every login |
| `/lm help` | the above |

## Things that will look like bugs and are not

- **The beacon disappears when you open your quest log.** Deliberate. We never compete for the
  supertrack slot — last explicit action wins — and `repin` is one click. The quest arrow
  matters more than our pin.
- **The beacon vanishes past ~1,500 yd.** That is the client's own cut, not ours. The map is
  the instrument at that range; `[Map]` appears and opens it.
- **Delete the only landmark carrying a tag and the tag stops suggesting.** There is no tag
  registry — we own no vocabulary, so a tag lives exactly as long as something carries it.
- **A deleted character's landmarks vanish.** They are still in the file. `/lm all` surfaces
  them, and the editor's transfer row moves them to you or to everyone.

## Where your data lives

`WTF/Account/<ACCOUNT>/SavedVariables/COA_Landmarks.lua` — **one account-wide file**, readable
without this addon and keyed by a legible id:

```lua
["Winterspring-Everlook-7"] = {
    alias = "Everlook 7", owner = "Gravekeeper",
    what = "", why = "", tags = "vendor, alt",
    icon = "questbonusobjective-supertracked", tier = "interact",
    x = …, y = …, z = …, mapID = 1, mapX = …, mapY = …, mapC = 1, mapZ = 25,
    zone = "Winterspring", subZone = "Everlook",
},
```

- **`owner` is `"global"` or a character name.** That one field does four jobs: who can see it,
  handing it to an alt, rescuing an orphan, and bulk transfer.
- **A position is never rewritten.** Rename, re-note, re-tier freely; a landmark cannot move.
- **`schemaVersion` gates the loader.** A version it does not know is **refused, loudly**, and
  nothing is touched — the addon will never guess at a shape and eat your scrapbook.

## Files

| | |
|---|---|
| `store.lua` | **the only file that touches `COA_LandmarksDB`.** A rewrite replaces this, not a search |
| `beacon.lua` | the slot discipline. **Two criteria here fail silently — see below** |
| `core.lua` | namespace, init, slash surface |
| `widget.lua` · `pins.lua` · `editor.lua` · `minimap.lua` | the surfaces |

**Before touching `beacon.lua`, read AC-24 and AC-26.** A map-boundary refusal reports
`distance = 0.00` — *not nil* — while still claiming to track, and zero satisfies every arrival
tier. Without the state guard, walking into any instance fires *arrived* and wipes the beacon.
Both are asserted in `addons/tools/smoke/smoke_landmarks.lua` and both were mutation-tested.

## Known issue

The beacon holds a **stale target** when re-pinned onto an already-live slot; re-selecting
takes. Parked deliberately — `landmark_design.md` §15 carries two candidate causes and the
single probe run that separates them. **Do not guess at it here.**
