# refs_signalfire - POISONED reference (study only, never our basis)

Ingested 2026-07-19 with the author's knowledge (joshxor/SignalFire, CurseForge + GitHub;
shallow clone, .git stripped). Standing: same as refs_threat - third-party source we STUDY to
understand baseline mechanics; nothing here is load-bearing, nothing gets copied into our
addons; our own bus work derives from the probed proposal
(addons/Materials/SignalFire_bus_proposal.md), not from this code.

census_map.json = its API surface joined against the clean-run runtime census
(record 20260717_043700): present / true-fork-gaps (self-declared globals filtered) /
C_* member verdicts. Read that first - it IS the how-it-works-baseline map.

## First-pass method (Battlewrath, 2026-07-19)

**Describe, do not anchor.** The first inspection pass reads what IS there - its own structures,
message formats, flows, naming - with NO reference to our bus proposal or use-case. Structure the
findings AS DATA inside this silo (per-file maps, message-shape tables, flow descriptions) so the
addon can be properly inspected and described on its own terms. Only after that description
stands does any join to our proposal happen, as a separate, later layer. (The census-map join
below was API-existence only; the mechanism pass follows this rule.)
