# Backlog: debug_suite

_Lifted at commit **ac41961** - the last commit with this code live._

driver.lua and walk.lua leave COA_DungeonRun - the recorder records, it does not drive and it does not test.

★ What the reconstruction owes: `addons/planning/debug_suite_plan.md`

⚠ **Nothing here is live.** `deploy.py`'s MANIFEST is keyed by addon folder
name, so this folder cannot reach a client.

---

## Whole files

- `driver.lua` - 328 lines, from `addons/COA_DungeonRun/driver.lua`
- `walk.lua` - 392 lines, from `addons/COA_DungeonRun/walk.lua`

## Mutations

`mutations.json` - **26** entries. Each is a guard with its own message;
the `find` anchors point at code that is about to move, so they are a
SPECIFICATION here rather than something runnable.

- [driver] the height check is applied
- [driver] the planar check is applied
- [driver] the radius is not squared twice
- [driver] no height requirement means a SPHERE
- [driver] a band is a tolerance, not a floor
- [driver] an unplaceable stage is refused (loudly)
- [driver] ★ THE RATCHET - an outcome can never walk the index backwards
- [driver] the band's DOWN half is judged separately
- [walk] the walk consults the height band
- [walk] a detector speaks once per visit
- [walk] leaving the radius re-arms the detector
- [walk] a held ratchet is reported, not silent
- [walk] set assigns without the max
- [walk] if-unseen blocks a repeat set
- [walk] the ledger records the stage that completed
- [walk] a stage with no acceptance is reported
- [walk] the action points at the goTo TARGET
- [walk] detect and action fire independently
- [walk] a dangling target is reported
- [walk] the next stage is found by LABEL, not by arithmetic
- [walk] the tracker goes to the on-ramp's own position
- [walk] past the last stage it still ANSWERS
- [walk] a childless beacon is its own detector
- [walk] the anchor satisfies without carrying a role
- [walk] the start report carries the unrunnable stages
- [walk] a bad route id reports a reason

## Smoke regions

`smoke_regions.lua` - **13** regions, 66 referencing lines.
⚠ Not runnable: the fixtures around them stayed behind.

## Call sites

- `core_verb_drive.lua` - `addons/COA_DungeonRun/core.lua:137-144`
- `core_verb_walk.lua` - `addons/COA_DungeonRun/core.lua:199-213`
- `promoter_play_button.lua` - `addons/COA_DungeonRun/promoter.lua:408-435`
- `promoter_play_registration.lua` - `addons/COA_DungeonRun/promoter.lua:482-483`
- `core_init_calls.lua` - `addons/COA_DungeonRun/core.lua:246-247`
