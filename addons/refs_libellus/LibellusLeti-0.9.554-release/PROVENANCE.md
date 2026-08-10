# Provenance — Libellus Leti, the "0.9.554" release asset

_Pulled 2026-08-08 for a version diff against the 0.9.553 dev drop. Poisoned-reference rules
apply: understanding + interop contract only, never copied._

## Source

- **Release page:** `https://github.com/ltgenzombie/Libellus-Leti/releases/tag/0.9.554`
  (published 2026-08-01 14:14 UTC, target commitish `main`).
- **Asset:** `LibellusLeti.zip`, 1,582.6 KB,
  sha256 `cf8bcab64cb20fe9faa912cda287a1c96e0604b6a3a4f3f9b58673b2589d15cd`.
- Downloaded to `Poison_risk/` (gitignored quarantine) and triaged BEFORE extraction:
  66 entries — 30 `.lua`, 1 `.toc`, 9 `.ttf`, 4 `.blp`, 15 `.tga`. **Zero executables, zero
  path-traversal entries, single top-level folder.** Media not copied here; code only.

## ★ THE VERSION SURFACES DISAGREE (three ways)

| surface | what it actually contains |
|---|---|
| git **tag** `0.9.554` | toc reads **`## Version: 0.9.434`**; lacks `InspectTree.lua` — a feature the 0.9.554 release notes advertise. 17 of 24 files byte-identical to our old 0.9.434 clone. **The repo source is NOT the released code.** |
| **release asset** on that same tag | toc reads **`## Version: 0.9.563`** — nine builds ahead of the release label it hangs under. Contains `WelcomeWizard.lua` + `Locale.lua` + 4 locale files, matching 554's notes. |
| the **dev drop** we were handed 2026-07-31 | toc reads `0.9.553`, but already carried 554's headline features (capital mute, InspectTree, miss tracking). |

**Consequence for any future work: the toc version string is not a reliable identity, and the
git tags are not the shipped code.** Identify a build by CONTENT (file hashes), not by label.
A silo built from a tag was created and then deleted during this pass precisely because its
name ("-0.9.554-tag") would have lied to a future reader about what it held.

## Diff vs the 0.9.553 dev drop (the build our perf measurement was taken on)

- **Added:** `WelcomeWizard.lua`, `Locale.lua`, `enUS.lua`, `deDE.lua`, `frFR.lua`, `ruRU.lua`
  (localisation extraction + the first-run wizard). **Removed: nothing.**
- **`MinionHpHud.lua` is BYTE-IDENTICAL.** So is `MinionSheet.lua`.
- **No timer/interval constant changed anywhere in the addon** (full scan across all files):
  `REFRESH_INTERVAL 0.5`, `NAMEPLATE_SYNC_INTERVAL 1.25`, `CLOAK_REASSERT_INTERVAL 0.30`,
  `CLOAK_SCAN_INTERVAL 0.50`, `RegenTracker.POLL_INTERVAL 0.05`, `ADVISOR_POLL_INTERVAL 2.0`
  etc. all unchanged.
- The other 23 shared files differ, consistent with localisation extraction (strings moving
  into the locale files) — not verified line-by-line.

## MancerLedger consumer contract — INTACT, no update needed

Re-verified in this build (see `addons/MancerLedger/DRIVER_CONTRACT.md`):
- `NewMinionBucket` still carries `misses = 0` (and the missTypes machinery).
- `MAX_SAVED_FIGHTS = 10` unchanged.
- `FightFingerprint` recipe unchanged: `"%.3f:%.3f:%.0f"` of
  `startedAt : endedAt : summed minion damage` — **our fold cursor still matches**.
- `MinionDps.lua` contains **no `OnUpdate` handlers**; every caller of `GetDpsEstimates` /
  `AggregateSessionStats` / `AggregateFightStats` sits inside an invoked path
  (`AggregateSessionStats`, `GetDpsEstimates`, `ResolveDpsFight`, `PrintComboRecommendation`).
  The pull-model finding holds.
