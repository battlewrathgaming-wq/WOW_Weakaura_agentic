# Pet parser — the scoping pass (2026-07-30)

_Answers the two pre-build questions: what is OBSERVABLE for the row grid, and how the
references compute. Design + spec: the ledger's top entry (Addons_load). Guardrail stands:
Libellus + Recount understood, not copied._

## Q1 — column observability audit (status per column)

| column | source | status |
|---|---|---|
| Name (individual) | registry: SPELL_SUMMON GUID + entry-id decode | **PROVEN** (guardian-tracker + plates records) |
| HP bar | plate-window UnitHealth | **PROVEN LIVE** (evidence pair; opportunistic per the no-CVar boundary) |
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

One `petlog` session task + one fight with the army out answers 1-4 in a single landed record.
Fight windows + accumulators come AFTER these facts are green (capture before display, standing).
