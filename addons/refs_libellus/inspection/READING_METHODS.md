# Libellus-Leti — game-reading methods, classified (understanding only)

_2026-07-30. Describe-don't-anchor; the guardrail (README) applies: mechanisms understood,
execution not copied. File sweep: `files.json`. Hot files: CombatLog (CLEU normalizer),
MinionDps (attribution + accumulator), MinionSheet/MinionHpHud (unit-read routes),
NecromancerAdvisor (191KB knowledge+advisor layer), PaperMath (owner paper-doll math)._

## Method 1 — CLEU layer: a runtime ARG-LAYOUT NORMALIZER (CombatLog.lua:20-105)

They treat the CLEU arg layout as UNSTABLE: try `CombatLogGetCurrentEventInfo()` (probing
for the retail backport), fall back to varargs with heuristic index-shifting (type-probing
for hideCaster/school-position variants), and STAMP every parse with which mode read it
("cleu" / "cleu-varargs" / "varargs"). Contrast with our approach (hardcode the observed
3.3.5 layout from BuffTrigger2.lua:3606): theirs is robust-by-detection, ours is
anchored-by-source. Understanding: layout instability is real in this ecosystem; a parse-mode
stamp is good capture hygiene either way.

## Method 2 — attribution: STATELESS sourceFlags classification (MinionDps.lua:94-98, 637-650)

No summon registry anywhere. Ownership is read PER EVENT from CLEU sourceFlags:
reject unless `AFFILIATION_MINE (0x1)`; accept on `OBJECT_TYPE_PET|GUARDIAN (0x1000|0x2000)`;
else accept `MINE+REACTION_FRIENDLY` or `MINE+CONTROL_PLAYER`. Properties vs our
GUID-registry primitive (guardian-tracker pattern):
- flags: stateless (reload-proof, zero backfill problem — every event self-describes),
  but CANNOT distinguish individuals, lifetimes, or pair snapshots to a specific summon.
- registry: stateful individuality (per-GUID lifetime, entry-id typing, owner-stat pairing),
  but has the backfill gap.
Understanding (not a copied design): the two are COMPLEMENTARY AXES of pet computing —
flags answer "is this mine," the registry answers "which of mine." A capture wanting both
properties uses both tests independently.

## Method 3 — unit-stat route: plate scan + preferred tokens + CVAR ENGINEERING (MinionSheet.lua)

Stats are read through whatever token currently resolves: preferred list
`{target, mouseover, focus, pet}` (:267) plus a `nameplate1..N` scan (:233, :351) — the same
plate-window route we proved independently. THE ADDITION: they manage the friendly-plate
CVars (`nameplateShowFriends`, `nameplateShowFriendlyGuardians`, `nameplateShowFriendlyPets`,
:25-27) — i.e., the "plate visibility is a hard runtime dependency" boundary we recorded is,
in their hands, a LEVER: flip the gates so minions become readable. Understanding: the
dependency is engineerable, with the UX cost of showing friendly plates.

## Method 4 — accumulator model: per-TYPE buckets, not per-individual (MinionDps.lua:296-307)

`{damage, hits, firstSeen, lastSeen, activeSeconds (sum of per-guid lifetimes), summonCount,
spells{}}` keyed by minion TYPE (abomination, crypt_fiend, ...). They answer "how do my
ghouls perform"; our banked design answers "what has EVERY abom ever looked like"
(per-individual, longitudinal, repo-side). Different questions; no collision.

## Layer worth noting, not mining: the ADVISOR content

A large hand-authored knowledge base (minion roles/LF costs/one-liners, FIGHT_ROLES,
temp-duration tables) — this is their TASTE/content layer, their equivalent of our class
inventories. Explicitly out of scope per the guardrail; also methodologically ours comes
from measurement (Class_design) not authored priors.

## Cross-checks banked for our own lanes (facts to verify, not code to take)

- Does this fork backport `CombatLogGetCurrentEventInfo`? (Their probe implies maybe —
  our census runtime can answer in one lookup.)
- The sourceFlags bits on THIS fork's CLEU (do guardians carry 0x2000 as expected?) — one
  landed capture verifies; feeds the petlog task design.
- Their CVar set = the exact lever list for making minions plate-readable (State Plates'
  guardian slice may want the same lever, user-consented).
