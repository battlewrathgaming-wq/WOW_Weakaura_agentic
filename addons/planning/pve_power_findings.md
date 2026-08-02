# PvE/PvP Power login bug — client-side investigation (2026-08-01)

_The community bug: on login, many specs lose ~30% damage because PvE (or PvP) power isn't
applied to the damage formula. Community fix = a ritual (gear sets, mode switch, naked death,
hard quit, corpse revive, re-equip). Goal of this investigation: can the broken state be
READ client-side, so players stop paying a dummy-test per login? Verdict: **no — by
construction.** Every claim below is walked, not assumed; references inline._

## Findings

**1. The server applies power as aura machinery.**
Spell.dbc (patch-T.MPQ) carries `PvE Power (+0)`…`(+99)` = spell ids **101600–101699**,
`PvP Power (+0..+99)` = **101700–101799**, plus 993xxxx-series variants, a QA spell
(`QA PvE Power (70)` 530150), and mode auras: `PvE Mode` **9931032**, `War Mode (PvP)`
**84420**, `War Mode` 300033.
_Walked via: `addons/tools/read_spell_dbc.py` (calibrated fork field map, self-verifying
anchors) + a substring scan over the decoded string block._

**2. The mode aura is visible; the power auras are fully suppressed.**
- `UnitAura` scan on a live character: only `PvE Mode 9931032` returns (also independently
  present in the petlog record `20260731_104452`'s aura sweep). No power aura listed.
- CLEU listener at login: **silent** — no power-aura APPLIED events.
- CLEU listener during a forced mid-session re-apply (unequip → re-equip a PvE-power item,
  listener provably alive): **silent**. This kills the timing explanation — the auras are
  suppressed from the combat log, not merely early.
_Walked via: three live probes run by Battlewrath (the UnitAura loop; the CLEU
varargs-position listener; the equip cycle)._

**3. The character sheet FABRICATES its display — the UI cannot show the bug.**
The display chain never consults the server:
- `PaperDollFrame.lua:684 PaperDollFrame_SetPvEPower` → displays `UnitPvEPower(unit)`.
- `UnitUtil.lua:36 UnitPvEPower` = client-side SUM of equipped items' `itemInfo.pvePower`.
- Tooltip lines (`+X% damage` etc.) = the same client sum × local constants
  (`PVE_POWER_DAMAGE_MULTIPLIER = 0.05`, `Constants.lua:842`).
- `C_Player.lua:189 UpdatePvEPower` — same gear-sum; `GlobalOverwrites.lua:53` injects
  `PVE_POWER` into `GetItemStats` from item info.
So the sheet always shows the EXPECTED value; the APPLIED value exists only server-side.
**The desync is invisible by construction.**
_Walked via: fresh patch-B extraction (`extract_interface.py`, re-run 2026-08-01) + grep
chain over FrameXML._

**4. Magnitude cross-check.** `PVE_POWER_CAP = 495` (`Constants.lua:841`) × 0.05 = +24.75%
damage at cap. Losing it ≈ dealing ~20% less; recovering ≈ "~25–30% more" — matches the
community's reported magnitude.

**5. Latent client bug found in passing (currently a no-op).**
`UnitUtil.lua` (~:49): `UnitPvEPower` clamps with **PVP**_POWER_CAP — wrong constant.
Both caps are 495 today (`Constants.lua:841/846`), so no visible effect — but it bites the
day the caps diverge. More importantly it PROVES the codebase contains PvE/PvP mix-ups of
this class, which motivates the labeled hypothesis below.

**6. Labeled HYPOTHESIS (not a claim — server code is closed to us):** the apply-path bug
may be a sibling mix-up — PvE/PvP power state tangled in the server's apply/refresh
machinery. Consistent with the fix ritual's shape (mode switch + naked + dead + hard quit =
forcing a full state reset) and with finding 5's precedent.

## What players CAN do (until a server fix)

Direct readout is impossible. The only honest client-side detector is **behavioral**: a
short dummy pull compared against a stored healthy per-hit baseline (~20%+ low = nerfed →
do the ritual). Mancer already buckets player spell damage per fight (`playerSpells`);
a small comparison layer over it (the MancerLedger profile method aimed at the player)
is the candidate build if the pain persists.
**UNVERIFIED PREMISE (Battlewrath's catch — do not build past it):** this assumes the
server applies the power multiplier at a pipeline stage REFLECTED IN CLEU damage amounts.
We have not walked where the increase is added. Supporting testimony only: the community
observed the ~30% deficit on dps meters (which read CLEU). Verification before any build:
one controlled A/B — same spell, same dummy, bugged login vs post-ritual — confirming the
per-hit CLEU amounts actually move.

## For the devs (the report package)

1. Fix the apply path (the actual bug).
2. **Expose applied power** — unhide the power aura or add an API returning the
   server-applied value. This is the structural fix: today players cannot distinguish
   applied from expected, which is why a 30% bug survived on vibes for 5+ days.
3. Fix the `PVP_POWER_CAP` clamp in `UnitPvEPower` before the caps ever diverge.
4. Audit the server apply path for the same PvE/PvP mix-up class as (3) — see finding 6.

## The walk, in order (method trail)

1. Fork UI source: fresh `patch-B.MPQ` extraction → grep for power vocabulary → the full
   display chain (finding 3).
2. `C_Player.lua` RULESETS (mode switches are spell casts) → mode/power spell hunt in
   Spell.dbc via the calibrated reader (finding 1).
3. Live probe 1: UnitAura scan → mode visible, power absent (finding 2a).
4. Live probe 2: CLEU listener at login → silent (finding 2b).
5. Live probe 3: CLEU listener + equip cycle → silent → suppression confirmed (finding 2c).
6. Back-trace of the paper-doll per Battlewrath's suggestion → fabrication confirmed
   (finding 3); constants read → magnitude cross-check (finding 4) + the latent cap bug
   downgraded to no-op after both caps read 495 (finding 5).
