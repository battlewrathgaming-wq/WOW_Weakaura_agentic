# Pet parser — the scoping pass (2026-07-30)

_Answers the two pre-build questions: what is OBSERVABLE for the row grid, and how the
references compute. Design + spec: the ledger's top entry (Addons_load). Guardrail stands:
Libellus + Recount understood, not copied._

## Q1 — column observability audit (status per column)

| column | source | status |
|---|---|---|
| Name (individual) | registry: SPELL_SUMMON GUID + entry-id decode | **PROVEN** (guardian-tracker + plates records) |
| HP bar | plate-window UnitHealth | **PROVEN LIVE** (evidence pair; opportunistic per the no-CVar boundary). DISPLAY RULE (Battlewrath 2026-07-30, refined — THE ANTI-FLICKER STATE MACHINE): per-row HP has 3 states: LIVE (plate-bound, colored, updating) · STALE (alive but plate dropped: GREY the field at last-known value, refresh on next plate window — TTL+update-on-refind, HIS earlier gap policy applied; rationale = the WA guardian-tracker's pain was plates flapping in/out making bars flicker; state-holding + grey kills the flicker) · GONE (died or TTL expired: the GUID ROW collapses out of the grid → archived to the exporter). COLUMN collapse only for the never-detected case (HP not observable at all this session) |
| Dmg / Taken | CLEU damage subevents by source/dest GUID | API proven; **pet-sourced events + flag bits = petlog v0 check** |
| crit% | CLEU critical flag | position CANONICAL (see the API finding); **live sample = v0 check** |
| miss% | SPELL_MISSED/SWING_MISSED miss types | same |
| Age/TTL | registry timestamps | **PROVEN** (pattern) |
| row weight v1 (LF cost) | OUR basis (talent data AECost/costs; Class_design can confirm) | derivation pass, offline |
| (lab) owner-stat pairs | UnitDamage/UnitAttackPower/UnitAttackSpeed/UnitArmor on plate tokens | **API EXISTS (census)**; behavior on pet tokens = v0 check |

**★ THE SCOPING FINDING: `CombatLogGetCurrentEventInfo` IS BACKPORTED (clean census, engine-side).**
The canonical retail CLEU read exists on this fork → petlog uses the zero-arg call and the
STANDARD tuple; every arg-position question (crit flag, school shifts, SWING vs SPELL shapes)
dissolves. Libellus's defensive varargs normalizer solves a problem this fork doesn't have.

## Q2 — how the references compute (understanding only)

**Recount (Tracker.lua/Recount.lua, silo refs_recount):**
- Flag classification, same era constants (PET 0x1000 / GUARDIAN 0x2000 / MINE / CONTROL_PLAYER),
  with local fallback defines.
- **Era fossil (Recount.lua:1112): "Guardians don't yet have unitids"** — stock 3.3.5 guardians
  had NO unit tokens, so Recount's whole guardian lane is built around that absence. OUR fork
  backports nameplate tokens → guardians DO have unitids here. Recount-era pet computing is
  designed for a constraint this client REMOVED.
- **The owner-resolution hack (:1195):** a hidden tooltip set to the guardian, reading
  "<Player>'s minion" from RecountTempTooltipTextLeft1 — the era's way to find a guardian's
  owner. We never need it: summon sourceGUID = owner (registry) and MINE flags (stateless).
- Display model: pets MERGE INTO the owner's row (AddPetCombatant). Ours inverts: pets ARE the
  rows. Same substrate, opposite lens.
- Fight segmentation (Current/LastFight/Overall windows) + Modes = per-metric extractors over
  accumulated tables. The window concept is worth having (fight-scoped Dmg column resets).

**Libellus (refs_libellus/inspection/READING_METHODS.md):** stateless flags attribution ·
plate-scan + preferred-token stat reads · CVar engineering (REJECTED for us) · per-TYPE buckets.

## The petlog v0 checklist (the ONLY remaining unknowns — all live facts)

1. `CombatLogGetCurrentEventInfo()` works inside a live CLEU handler (one capture proves).
2. Pet/guardian-sourced damage appears in CLEU with the expected flag bits (0x1000/0x2000 + MINE)
   on THIS fork (Necro minions are the test payload).
3. Stat reads (`UnitDamage`/`UnitAttackPower`/`UnitAttackSpeed`) return REAL values on
   plate-bound pet tokens (pair with owner stats same-tick = the scaling-lab row).
4. Miss-type strings on the fork (DODGE/PARRY/MISS vocabulary as expected).
5. LF-cost table derived from our basis (offline; no client needed).

6. **THE LIVE VALIDATION PASS (Battlewrath, 2026-07-30): registry count == guardian-buff STACK
   count.** The Necro's minion-count buff (the corpus minion-count-tracker pattern's read) is an
   independent live witness of "how many are up" — the grid continuously checks
   #activeRows == buffStacks. Match = registry proven in-flight; mismatch = drift detected
   (missed summon/death) → flag it, and it's the natural trigger for a resync/backfill. The
   two-witness house pattern, running CONTINUOUSLY inside the addon.

One `petlog` session task + one fight with the army out answers 1-4 in a single landed record.
Fight windows + accumulators come AFTER these facts are green (capture before display, standing).

## PIVOT (Battlewrath, 2026-07-30): FAMILY LIFETIME NORMALS replace the history exporter

On row expiry (death/TTL) the individual FOLDS into its pet-family's running aggregates
(count, damage, hit/crit/miss samples, activeSeconds -> "what a ghoul generally does",
self-normalizing through play). RESETTABLE, bounded in SV - kills variable bloat. Two tiers:
LIVE = per-GUID individuals (the grid) · ARCHIVE = per-TYPE normals (converges on Libellus's
buckets but as the archive tier only). Family normals also solve the crit/miss sample-floor at
population scale. CARVE-OUT: the scaling-lab pairs (owner x pet stat snapshots) stay RAW and
land via the existing mailbox lane on deliberate lab sessions only (Class_design parses
offline) - no standing exporter machinery at all.

## Q3 - presentation method (2026-07-30; the one unproven lane, honestly named)

We have built stable STATIC frames (the satellite options panels) but never a live updating
display element. METHOD CHOICE: native hand-rolled micro-frame - CreateFrame container +
POOLED row frames (fontstrings + one statusbar per row). Rejected: Ace/LibGraph libraries
(Recount's route - big-pane DNA, dependencies) and WA-as-display (accumulator state lives
addon-side anyway; splitting across the bridge buys complexity). The fact basis carries the
idioms: patch-B's CompactUnitFrame IS this fork's row element, readable end to end.

THE FIVE STABILITY CONCERNS: (1) create-once + row POOLING (rows attach/detach to GUIDs, never
recreated); (2) position persistence (anchor in SV, drag + lock); (3) update discipline -
event-driven writes to existing regions, no per-frame re-layout (our render-economics findings
applied from birth); (4) scale + visibility modes (cheap on a sound container); (5) lockdown:
none - display-only frames are unprotected (click-to-target rows would need secure templates;
deferred).

BUILD SHAPE (prototype before polish, the house two-step applied): a throwaway STUB pass first -
one movable/lockable/persisting container, three fake rows, dummy-data ticker - proves the
element primitives in isolation (the UI equivalent of the smoke harness). The real grid then
mounts the proven chassis with petlog data. Two small passes, not one entangled one.
