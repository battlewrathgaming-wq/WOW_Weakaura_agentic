# AggroHighlight Saga - Index

Everything from the native aggroHighlight investigation (COA_GuardianPlates v3.5.16 - v3.5.42), flattened into one place now that the topic is closed out for the time being.

## What this was about

Enemy nameplates show two threat signals: this addon's own hand-rolled glow (reliable, production-primary since v3.5.29) and Ascension_NamePlates' built-in red "you have aggro" highlight. The goal was to recolor or disable that native highlight so it stops competing visually with the addon's own signal.

## Files in this folder

- **FINDINGS.md** - the research narrative: confirmed structure, the re-assert race, the real driver function (eventually identified as a CompactUnitFrame backport), diagnostic tools and their results, external research context.
- **CHANGELOG.md** - the clean version-by-version record (v3.5.16-v3.5.42), extracted from the addon's .toc, plus the final live-test result that isn't tied to any version bump.
- **CODE_MAP.md** - exact function names and line numbers in Core.lua/EnemyPlates.lua, the relevant `/coasp` slash commands, and the working `/run` macros for testing without a client reload.

## Where it stands

Production is unaffected and unchanged: the hand-rolled glow is still the only thing that actually controls nameplate coloring. The native recolor (v3.5.40) and suppress (v3.5.42) hooks are built, use a mechanism now confirmed to reach the real driver, but are not wired into production and haven't been confirmed holding on screen yet. A live macro test of the suppress concept showed no visible effect, cause unknown. Paused for testing fatigue, not because anything is broken or dead-ended.

## Picking this back up later

1. Read CHANGELOG.md's final entry first - that's exactly where things left off.
2. The `suppressaggro`/`SetNativeAggroHighlightColor` primitives will load automatically on Battlewrath's next natural full client restart (no forced reload needed).
3. Task #266 ("Build focus indicator - static glow for current target") is still pending and was the original motivation for wanting to disable the native highlight in the first place.
