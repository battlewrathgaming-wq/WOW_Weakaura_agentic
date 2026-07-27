# Build capture — the live second witness (handover from the addons bench, 2026-07-27)

_The recurring loop for pulling a character's ACTUAL build into this lane, validated two-witness
against the decoder. Acceptance run: Reaper `20260727_043239_714` + panel-closed re-verify
`_045725_284` — reconciliation clean, one real plan-drift exposed (Dreadknight r2 vs r1)._

## The loop (per character / per respec / per candidate build)

1. **In-game:** `/coadump r talents` → one summary line → `/reload`.
   Pure `C_CharacterAdvancement` getters (the client's own CA-UI call shapes) — works with the
   talent panel CLOSED, any spec, no addon state. The watcher (addons bench terminal, key `[1]`)
   lands the record at `addons/landing/records/<runId>__talents.json`.
2. **Offline:** `py addons\tools\diff_talents.py "<ascension.gg export string or share URL>"
   [record.json]` (defaults to the newest talents record).

## Reading the output

- `MATCH` / `matched nodes` — the witnesses agree; is-selected is clean.
- `TARGETS (planned-not-known)` — in the plan, not on the character: **what to select next.**
- `rank differs ... -> TARGET` — under-ranked vs plan.
- `known-not-planned` — on the character, not in the plan: plan-drift (update the plan or
  reclaim the point). Example live: Dreadknight r2 in-game vs r1 in the saved string.

## The record (what this lane can mine beyond the diff)

Each entry = raw scalars + key inventory + arrays. 37 fields per talent node including
**`ConnectedNodes`, `RequiredIDs`, `Spells` (the per-rank spellId family), Tab/Row/Column/
Position, Quality, the full cost/investment matrix** — tree TOPOLOGY and prerequisites, not just
selection. Compounding-talent reasoning can run graph-shaped on this.

## Standing facts + caveats

- **Builder strings list EACH RANK as its own spellId** (Soul Warden = 560419 r1 + 561337 r2).
  The diff joins via the captured `Spells` array — self-contained, no repo lookup.
- **Spec-GRANTED abilities are outside the build contract in BOTH witnesses** (e.g. Reaper
  Dreadwake 803992 / advancement 30720, granted on spec pick; spec passives like Behemoth/Soul
  Slip likewise). Their absence is consistency, not a gap.
- **`GetTalentRankByID` maxRank quirk:** returned maxRank 1 for Soul Warden where the builder
  says maxPoints 2 — treat the builder's maxPoints as the cap authority until probed.
- `ExportBuild()` returned nothing bare — likely wants args; unchased. The ascension.gg string
  remains the plan-side witness.
- Records are runId-immutable; `/reload` between runs (the mailbox holds ONE run).

## Ownership

The capture harness (task, watcher, deploy) is the ADDONS bench's; this loop and the diff's
consumers are YOURS. Task changes → ask the addons bench (addons/backlog.md, the standing
cross-lane pattern). `diff_talents.py` imports `decode_build.py` — one codec, one source of truth.
