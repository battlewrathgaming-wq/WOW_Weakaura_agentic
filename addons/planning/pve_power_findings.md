# PvE/PvP Power login bug — client-side investigation (2026-08-01)

_The community bug: on login, many specs lose ~30% damage because PvE (or PvP) power isn't
applied to the damage formula. Community fix = a ritual (gear sets, mode switch, naked death,
hard quit, corpse revive, re-equip). Goal of this investigation: can the broken state be
READ client-side, so players stop paying a dummy-test per login? Verdict: **no — by
construction.** Every claim below is walked, not assumed; references inline._

## Findings

**1. Power-NAMED spell entries exist — but are NOT the application mechanism
(CORRECTED 2026-08-01 by dev statement + our own probe data).**
Spell.dbc (patch-T.MPQ) carries `PvE Power (+0)`…`(+99)` = spell ids **101600–101699**,
`PvP Power (+0..+99)` = **101700–101799**, plus 993xxxx variants and mode auras (`PvE Mode`
**9931032**, `War Mode (PvP)` **84420**). We initially framed these as the server's
application machinery — an inference from DBC presence. **Dev (Grey/ASC): "PvE power isn't
an aura. That's just a tooltip display."** Our own probes already pointed there (the auras
never fire, even on a forced re-apply — finding 2); DBC presence ≠ mechanism. The actual
application is a server-internal stat with NO client-side representation at all. Grey
further notes the damage deficit's attribution to PvE power itself is NOT confirmed —
"there's a problem for sure, but in terms of it being PvE power, it's not actually clear."
_Walked via: `addons/tools/read_spell_dbc.py` + substring scan; corrected via dev statement._

**2. The mode aura is visible; the power auras are fully suppressed.**
- `UnitAura` scan on a live character: only `PvE Mode 9931032` returns (also independently
  present in the petlog record `20260731_104452`'s aura sweep). No power aura listed.
- CLEU listener at login: **silent** — no power-aura APPLIED events.
- CLEU listener during a forced mid-session re-apply (unequip → re-equip a PvE-power item,
  listener provably alive): **silent**.
- **Listener instrument VALIDATED** (2026-08-01): the same listener caught
  `SPELL_AURA_REMOVED 707194 Life For Power` live — the power-aura silence was real
  silence from a working probe, not a broken test.
- Post-correction reading: the silence isn't suppression of active machinery — the power
  spells simply never run (consistent with finding 1's correction: tooltip artifacts).
_Walked via: three live probes run by Battlewrath (the UnitAura loop; the CLEU
varargs-position listener; the equip cycle) + the 707194 validation catch._

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

**4b. The gating table (dev-authored intent — GlobalStrings.dbc, patch-M):**
PvE Power damage = "against creatures" (TARGET-gated, no mode/zone condition) · PvE
healing/absorb = INSTANCES only · PvP Power damage = "against players" · PvP Power gains a
creature-damage clause ONLY in High-Risk open world. Consequences: training dummies
(creatures; entry 666938 = L63 elite, boss defense table) ARE valid PvE-power reflectors by
design — the community's dummy testing measures the right surface; and a High-Risk tester
hits TWO stacked lanes on a dummy, so baselines belong in plain PvE mode. (Client intent
text; the server implements the actual gate — corroborated behaviorally by the community's
observed before/after dummy deltas.)

**5. Latent client bug found in passing (currently a no-op).**
`UnitUtil.lua` (~:49): `UnitPvEPower` clamps with **PVP**_POWER_CAP — wrong constant.
Both caps are 495 today (`Constants.lua:841/846`), so no visible effect — but it bites the
day the caps diverge. More importantly it PROVES the codebase contains PvE/PvP mix-ups of
this class, which motivates the labeled hypothesis below.

**6. Labeled HYPOTHESIS (not a claim — server code is closed to us):** the apply-path bug
may be a sibling mix-up — PvE/PvP power state tangled in the server's apply/refresh
machinery. Consistent with the fix ritual's shape (mode switch + naked + dead + hard quit =
forcing a full state reset) and with finding 5's precedent.

## The detection boundary (finding, not solution)

Direct readout is impossible (findings 2–3). The only detection CLASS remaining
client-side is **behavioral** — comparing observed combat output against a known-healthy
baseline. This document makes no tooling proposal; any build in that class is a separate,
ungated consideration, and it rests on an **unverified premise (Battlewrath's catch)**:
that the server applies the multiplier at a pipeline stage reflected in CLEU damage
amounts. We have not walked where the increase is added. Supporting testimony only: the
community observed the ~30% deficit on dps meters (which read CLEU). The premise is
settled by one controlled A/B — same spell, same dummy, bugged login vs post-ritual —
confirming the per-hit CLEU amounts actually move.

## For the devs (the report package — updated after Grey's statement)

1. Fix the damage deficit (root cause per Grey NOT yet confirmed to be PvE power — the
   deficit is real, the attribution is open).
2. **Expose the applied value via API** — there is no aura to unhide (per Grey); an API
   returning the server-applied stat is the ONLY possible verification surface. Today
   players cannot distinguish applied from expected, which is why a ~30% deficit survived
   on vibes for 5+ days.
3. Fix the `PVP_POWER_CAP` clamp in `UnitPvEPower` before the caps ever diverge.
4. (Weakened by Grey's attribution caveat, kept as labeled hypothesis:) audit the apply/
   init path for state that survives login incorrectly — see findings 6 and the ritual
   inference.

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
