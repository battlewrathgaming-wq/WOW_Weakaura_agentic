# Mancer findings bank (held — loaded for when the standing warrants)

_All findings 2026-07-31, from one day of first-user testing (Battlewrath is the only known
Mancer × TurboPlates user). Strategy: bank everything, prove MancerLedger's utility FIRST,
then engage carrying working software whose own behaviour demonstrates every principle the
feedback asks for: **opt-in · the consumer/game source drives updates · dedupe**. The
credibility is the addon, not the argument._

## Finding 1 — the CVar three-lane corruption class (design)

**What:** three separate backup/restore lanes write the same nameplate CVars — capital mute
(8 keys, Core.lua), Minion Sheet boost (3 keys), HP HUD boost (3 keys) — each snapshotting
"user prefs" at its own moment. Replay-then-CLEAR semantics bake any mid-dance mis-snapshot in
permanently and unattributably. First-load-in-a-capital is the MODAL new-user case (cities are
where people log out), and settings-poking (the natural first-session behaviour) multiplies
the windows. Their own comments patch two instances of the class ("Contaminated backup (all
'1') from nesting under Sheet — drop it"; "Drop Minion HP boost first so we snapshot the
user's real prefs").

**Evidence:** cvarlog record `20260731_143305_100` (mute engaging: 8 CVars zeroed one tick,
capitalNameplateCvarBackup appears same instant, clean restore 2s later). Live specimen:
Battlewrath's guardians-only residue (config he never set, surviving after leaving the city).
The mute default is opt-OUT by absence: `disableNameplatesInCapitals ~= false` — nothing is
ever written to say "on"; a fresh install has active CVar management with nothing in its
config to show for it.

**Fix shapes (cheapest first):**
1. A never-cleared `lastKnownUserPrefs` — restores replay it but never consume it; no
   mis-snapshot can become the new truth.
2. Snapshot once at login BEFORE any addon write; that snapshot is the session's only truth.
3. One plate-CVar owner lane all three systems request through (the same centralization they
   already built for minion GUID tracking).
4. First-run consent prompt for the capital mute ("manage nameplates in cities for FPS?") —
   dissolves the class and makes the feature discoverable.

## Finding 2 — guardian plate suppression is a polling race (mechanical bug)

**What:** the cloak driver polls — full plate discovery ~2/sec, re-hide pass ~3/sec
(MinionHpHud.lua, CLOAK_SCAN/REASSERT intervals). The client recycles plate frames constantly;
every recycle shows the plate until the next pass. Observed live (TurboPlates disabled, so no
interaction): suppression holds ~95% of the time with a trailing FLASH each cycle. Polling
cannot win this race at any cadence — faster polling just converts flash-time into CPU.

**Fix shape:** hook, don't poll — at discovery, hook each plate frame's `OnShow` once so the
hide fires inside the show itself. Zero-frame flash, the reassert loop deletes entirely (its
per-frame cost with it), and discovery can go slow because hooks persist on recycled frames.
Same event-over-polling principle their CLEU fight commits already follow.

## Finding 3 — the hitching, attributed (performance, profiler-proven)

**What:** "rough lag / locking" in a capital. Isolation arms: PetGrid off, MancerLedger off,
TurboPlates off → still hitching with Mancer alone. Then scriptProfile attribution.

**Evidence:** perf record `20260731_152651_494` (scriptProfile=1, watched all four addons):
- **LibellusLeti: 3,111ms CPU / 131s = ~24ms/sec steady-state, spikes 48–108ms in single
  seconds. ALL EIGHT worst fps seconds (troughs to 31 from avg 92) align with a Mancer spike
  in that exact second. 8 for 8.**
- MancerLedger 0.0ms (the 1.5s-harvest hunch formally acquitted — event-driven, free at idle).
- COA_DevDump 0.1ms/sec (the sampler's own heartbeat). TurboPlates 0 (disabled).
- Frame budget at 95fps ≈ 10ms; a 100ms burst inside one second = the felt lock.

**Read:** ~24ms/sec baseline = the always-running HUD ticker (MinionHpHud.lua:1664 —
deliberately unconditional, their comment explains why) + suppression cadence; the bursts =
periodic full plate-discovery sweeps. Finding 2's fix removes a slice of both.

**★ THE NARROWING (source-traced, re-verified 2026-08-08 on Battlewrath's prompt):** the
report/aggregation layer is **PULL-MODEL and clean** — every caller of `GetDpsEstimates` /
`AggregateSessionStats` / `AggregateFightStats` resolves to an INVOKED path, never a timer:
`ResolveDpsFight` (Hub DPS view render) · `PrintComboRecommendation` (command) ·
`AugmentTooltip`+`GetCalibratedUnitDps` (hover, gated by tooltipEnabled) · `PrintInspect`
(command) · `PaperMath:PrintReport` (command). Panes closed = zero aggregation cost.
**Therefore the measured cost is NOT the data product — it is the always-on scaffolding**
(unconditionally-installed OnUpdate handlers: RegenTracker 0.05s, two icon-pulse 0.05s
loops, the HUD ticker) plus population-scaled plate work. This both credits their
architecture and narrows the search — the strongest form of the lead.

**Supporting:** earlier unattributed runs `20260731_151539` (min 28 / avg 83) and
`20260731_152232` (min 30 / avg 94) — same trough shape, three independent captures.

**★ INDEPENDENT REPRODUCTION (2026-08-08, Discord):** user TruxXx reports "when this add-on
is activated, the game stutters continuously, like every second or two seconds you feel a
flicker on the screen." No TurboPlates mentioned → the hitch is NOT a
Battlewrath-specific interaction. LtGenZombie is ACTIVELY SOLICITING diagnostics (version /
other addons / settings) — our isolation arms already answered that question mechanically
(PetGrid off, MancerLedger off, TurboPlates off → still hitching with Mancer alone).

**Spike periodicity (re-analysis of `20260731_152651_494`):** 17 of 130 seconds carry a
>40ms Mancer burst, on a **~8s cadence** (median gap 8.0s, mean 7.7s); fps at spike seconds
averages 55 vs 97 quiet. NOTE THE METHOD LIMIT: 1-second sampling CANNOT resolve per-frame
hitches — a 24ms/sec steady state is invisible if spread over 60 frames and a dropped frame
every second if concentrated. The reporter's "every second or two" is consistent with the
concentrated case but **our data cannot prove the flicker cadence**; a frame-time sampler
would be required to measure it.

**Timer inventory (source read, 0.9.553 — HYPOTHESES for the reported cadence, not proven):**
unconditional 20/sec pollers exist (`RegenTracker.POLL_INTERVAL = 0.05`, two
`ICON_PULSE_INTERVAL = 0.05` in FloatingText + NecromancerAdvisor); and the reporter's
stated 1–2s cadence matches `RegenTracker.DISPLAY_INTERVAL = 1.95` / `REGEN_TICK_SECONDS = 2`
/ `ADVISOR_POLL_INTERVAL = 2.0`. RegenTracker's `OnUpdate` is installed unconditionally at
init (no shown-state gate) — same pattern as the HUD ticker. Other cadences: CLOAK_REASSERT
0.30 · CLOAK_SCAN/HUD REFRESH 0.50 · SPELL_CD_SYNC 0.25 · ALERT_REFRESH 0.35 ·
NAMEPLATE_SYNC 1.25 · UNIT_SCAN 3.0 · MinionSheet REFRESH 5.0 · GUARDIAN_SEED 5.0.

## Relay notes

- Finding 2 is the icebreaker: small, provably real, flattering to fix, and only visible to a
  TurboPlates-less eye watching guardians — data he's never had.
- Finding 3 pairs with it (same hook-don't-poll fix erases a slice of the CPU), and profiler
  tables don't argue — every other addon's innocence is in the same table.
- Finding 1 is the design conversation; it lands best LAST, after credibility, and its consent
  framing is already seeded in the Discord thread (opt-in, discovering a feature at a time,
  user trust — his words on record, 2026-07-31 2:45 PM).
- The demonstration piece is MancerLedger itself: opt-in by construction (nothing folds until
  a profile is made), the driver's own data is the sole source (read-only, no client-state
  writes, no CVars touched), fingerprint dedupe (their own recipe, honoured). We advocate
  nothing we don't ship.

## Status

HELD — but the hold's premise changed 2026-08-08 (see Finding 3's reproduction note).
The hold existed because Battlewrath was new to their community and did not want to arrive
with a razor edge on UX. That reasoning covers Findings 1 and 2 (design/UX critique). It
does NOT obviously cover Finding 3: a pure profiler measurement, no design opinion, of a
symptom a SECOND user has now reported and the author is actively asking diagnostic
questions about. Relay decision remains Battlewrath's.

Next (unchanged): prove ledger utility through ordinary play.
