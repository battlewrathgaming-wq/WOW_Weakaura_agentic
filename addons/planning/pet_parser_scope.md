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

**★ OVERTURNED LIVE (petlog record 20260731_104452): `CombatLogGetCurrentEventInfo` EXISTS but
is FURNITURE at the handler level.** canonApi=true, yet all 4000 rows fell through to varargs —
the global returns nothing useful inside a live CLEU handler. A stored global isn't live; check
consumption (the census proved existence, only the capture proved behavior). The real layout is
the CLASSIC 3.3.5 varargs tuple, now VERIFIED positionally from the data:
`1 ts · 2 subevent · 3 srcGUID · 4 srcName · 5 srcFlags · 6 dstGUID · 7 dstName · 8 dstFlags ·
9+ suffix` (no hideCaster). Suffix positions confirmed: SWING_MISSED missType=9;
SWING_DAMAGE amount=9, critical=15; SPELL_DAMAGE spellId=9, amount=12, critical=18.
Libellus's varargs normalizer solves a problem this fork DOES have; petlog's fallback-first
design meant zero data loss.

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

## The petlog v0 checklist — VERDICTS (record 20260731_104452_749, 4000 events / 126 snapshots / 71 summons)

1. `CombatLogGetCurrentEventInfo()` in a live handler → **NO** (exists, answers nothing;
   varargs is the real path — see the overturned finding above). Handled by design; no data lost.
2. Pet-sourced CLEU flag bits → **GREEN, with a correction**: Necro minions carry
   **TYPE_PET (0x1000), NOT TYPE_GUARDIAN (0x2000)**. srcFlags = 0x1111
   (MINE + REACTION_FRIENDLY + CONTROL_PLAYER + TYPE_PET) on 2677 of 2678 registry-sourced rows
   (1 stray 0xa28 row — likely server GUID reuse; noted, ignorable at 0.04%).
3. Plate-bound stat reads → **GREEN**: real values (sample: pet AP 985, dmg 286.8–305.6,
   atkSpeed 2.42s) paired same-tick with owner (AP 149, stamina 234, shadow SP 326).
   124/126 snapshots carried pets. The scaling-lab row shape works.
4. Miss vocabulary → **GREEN**: DODGE ×19, MISS ×17 at pos 9 (no PARRY in sample — target mix,
   not an absence claim). Crit flags: SWING 112/728 crit, SPELL 78/896 crit at the era positions.
5. **LF-cost table — DERIVED (2026-07-31, from Input talents "occupying N Life Force" +
   coa_spells.json).** The v1 row-weight data:

   | Raise (LF-weighted rows) | LF | | Animate (family rows) | TTL |
   |---|---|---|---|---|
   | Raise: Ghoul 500971 | 1 | | Animate: Zombie (powerType 6) | 15s |
   | Raise: Banshee 504861 | 2 | | Animate: Skeletal Archer 805040 (×3) | 15s (+3 talent) |
   | Raise: Skeletal Mage 500331 | 2 | | Animate: Tomb King 805044 | 15s |
   | Raise: Abomination 500335 | 3 | | Animate: Bone Wraith 805032 | 15s |
   | Raise: Decaying Colossus 500989 | 3 | | Animate: Plaguefather 805048 | 15s |
   | Raise: Gargoyle 500329 | 3 | | Animate: Bone Construct 531130 | 20s |
   | Raise: Lesser Skeletal Warrior (r1) | 1 | | Animate: Frost Wyrm 805428 | 30s |
   | Raise: Greater Skeletal Warrior (r2) | 1 | | Animate: Greater Zombie | 15s (both summoning talents) |

   (CORRECTED, Battlewrath 2026-07-31: Bone King is NOT a summon at all — a Command: Undead
   proc buff granting a free instant Blight/Lich Frost. Excluded from the parser entirely;
   the coa_spells proc entry described the buff, and I mis-slotted it as a minion.)
   **GAPS CLOSED (Battlewrath, 2026-07-31, class knowledge):** Skeletal Warrior = 1 LF both
   ranks (the starter guardian type — you begin with it). Greater Zombie = 15s across both
   talents that summon them. Bone Construct 20s CONFIRMED live (matches the derived value —
   two-witness green). The table is complete; no fallbacks needed.

6. **The validation witness — INSTANCE-counted, not stack-counted (Battlewrath, 2026-07-31).**
   The minion buffs (Ghoul 805019, Abomination 805017, Decaying Colossus
   805022, Lesser/Greater Skeletal Warrior 805016/807927) manifest as ONE SEPARATE BUFF
   INSTANCE PER INDIVIDUAL — 3 ghouls = 3 "Ghoul" auras each at count 1, not one buff at
   stack 3. Record-confirmed: Decaying Colossus ×2 simultaneous instances in one sweep (the
   only moment the fight had type-siblings up). The invariant is the FULL count equality:
   per-type aura-instance count == per-type registry alive count. Reading it = the UnitAura
   index walk counting instances per spellId (sweep depth is safe: max 16 of 40 slots used).
   ★ AND IT'S THE DEATH SIGNAL: since UNIT_DIED is silent, an instance count dropping (3→2)
   IS the per-type death/despawn event — the registry then attributes WHICH GUID via plate
   absence + activity recency. The buff sweep is the liveness AUTHORITY for count-per-type;
   CLEU attributes individuals. Coverage rim: the Animate swarm has NO buff witness (no
   Zombie aura in the record) — swarm liveness stays TTL-governed.
   (NOT census entries, just procs riding the same sweep: Diabolical 707133 [stacks to 7] and
   Bone King 707176 — Battlewrath: a Command: Undead proc granting a free instant
   Blight/Lich Frost, NOT a summon. Adjacency in the aura list ≠ membership; the witness
   list is curated by class knowledge, not inferred from sweep proximity.)

## THE LIVENESS FINDING (the record's biggest design fact)

**UNIT_DIED never fired for a single one of 71 registered pets — but SCOPE THE CLAIM
(corrected 2026-07-31, Battlewrath): no pet died to an enemy in this sample.** What the
record PROVES silent is re-summon OVERWRITE (Abomination ×2, Tomb King ×2, Greater Zombie ×2 —
the replaced pet just despawns, no event). Death-by-enemy is UNTESTED, not disproven — a
capture where enemies kill pets would settle it. The design conclusion survives on the
overwrite fact alone:
**the grid cannot key row-collapse on UNIT_DIED.** Liveness derives from the composite:
the per-type buff-instance count as AUTHORITY (see checklist 6 — an instance drop IS the
death event for Raise types) + activity-TTL and plate presence to attribute which GUID;
UNIT_DIED is a bonus fast-path when it happens to fire. The Animate swarm (no buff) is
TTL-only.

**Two summon lanes, structurally different:**
- **Raise:** (Abomination/Ghoul/Skeletal Warriors…) — the persistent army, one-per-slot,
  overwrite-on-resummon. These are the grid's natural rows and the scaling-lab subjects.
- **Animate:** (Zombie ×36 over 148s, Tomb King, Plaguefather, Greater Zombie) — the
  corpse-consumption lane; zombies are an ephemeral SWARM.

**Plate-coverage rim:** only 7 of 71 GUIDs were ever plate-bound (max 7/tick, avg 4.2) — the
persistent army gets HP/stats; the swarm largely never does. HP column honest for Raise pets,
mostly STALE/absent for Animate zombies.

**SWARM ROWS — RATIFIED (Battlewrath, 2026-07-31).** Animates are TEMP summons: no per-GUID
UI rows, expected to die by TTL, and **no nameplate expected by design** (the record agrees —
zombies essentially never plate-bound). The grid SUB-DIVIDES:
- **Raise section** — per-GUID individual rows (the spec'd columns, LF-cost weight, buff-instance
  liveness authority).
- **Animate section** — per-FAMILY normalized rows: `[name][count][stat][stat][stat]`. No HP
  column (unobservable by design, not a choice). Families: Zombies, Archers, Tomb King,
  Plaguefather — the exclusives are just families of max-1, same shape, same normalization.
  Count = live count (TTL-decayed). The stat slots draw from the rate-first set per NORMALS
  DISCIPLINE (crit%/miss% lead; damage as labeled raw totals only); exact picks at build.
CLEU still tracks Animate GUIDs internally (attribution needs them); the family collapse is a
UI/aggregation fact, not a capture fact.

Fight windows + accumulators come AFTER these facts are green (capture before display, standing).
Facts 1–4 + 6 are now settled; 5 is offline derivation; the swarm-row question is the one
design gate left before the grid mounts.

## PIVOT (Battlewrath, 2026-07-30): FAMILY LIFETIME NORMALS replace the history exporter

On row expiry (death/TTL) the individual FOLDS into its pet-family's running aggregates
(count, damage, hit/crit/miss samples, activeSeconds -> "what a ghoul generally does",
self-normalizing through play). RESETTABLE, bounded in SV - kills variable bloat. Two tiers:
LIVE = per-GUID individuals (the grid) · ARCHIVE = per-TYPE normals (converges on Libellus's
buckets but as the archive tier only). Family normals also solve the crit/miss sample-floor at
population scale.
**NORMALS DISCIPLINE (Battlewrath, 2026-07-30): rates first, damage carefully.** The addon
CLAIMS NOTHING about scaling. Family normals lead with the RATE stats (crit% / miss% /
dodge-parry breakdown - per-attempt ratios, self-normalizing regardless of target count);
DAMAGE is context-soaked (40-target AoE vs single-target = massive sample bias) and is NEVER
presented as a normalized family value - live-fight column + clearly-labeled raw totals only.
Avg-hit-per-swing MAY appear as a secondary with an explicit context caveat. CARVE-OUT: the scaling-lab pairs (owner x pet stat snapshots) stay RAW and
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

**CHASSIS PROVEN LIVE (2026-07-31, COA_PetGrid v0.1.x through one full review round with
Battlewrath).** Survived: pooling/no-flicker, drag+lock+scale SV persistence, demo 3-state
cycle, addon off/on. Live-caught + fixed in the round: stat/bar clipping (layout rebalance);
HP overlay added then refined to % (healthy-or-not read); column-label headers; the family-row
hole became the TTL WINDOW (same pooled bar, section semantics - reads "time until count next
drops"); ★ GROW-DOWN: container pinned by TOP-LEFT (UIParent-space, scale-corrected), with a
one-shot pinner deferring anchor conversion past ADDON_LOADED because frames have NO rect there
(the legacy bottom anchor survived the naive load-time conversion - a lesson with State Plates'
delta-guard flavor: apply-time vs load-time validity). Pass 3 = mount the real feed.
