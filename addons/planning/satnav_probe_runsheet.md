# satnav probe — execution card

**One session, one pin, three manoeuvres.** Answers the three questions blocking the landmark
design brief. Instrument: `COA_DevDump/task_satnav.lua` · smoke: `addons/tools/smoke/smoke_satnav.lua`
(green) · ledger: `addons/planning/satnav_ledger.md` §7, F21–F27, laws 13–15.

Pure capture. The task draws no conclusions and neither should the chat line — the record is
read in the repo.

---

## Pre-flight

1. **Close the game.** Then deploy: `addons/menu.bat` → deploy (or `py addons\deploy.py`).
2. Launch, log in.
3. **Check the CVar.** The task reports it, but if it is off nothing renders:

```bash
/console showInGameNavigation 1
```

4. **★ Pick the pin spot deliberately — it has to satisfy all three tests at once:**
   - a **floor directly above it** you can walk to (an inn or bank upper storey), for (A)
   - **near a zone border**, for (C) — *Orgrimmar just inside the gates* is close to ideal:
     stepping out into Durotar changes mapID within a couple of hundred yards.

> **Why "near the border" is not optional.** F22: anything past **1500 yd** is forced to
> `NavigationState.Invalid` regardless of zone. Run (C) from far away and a distance-cut reads
> exactly like *the engine refuses cross-zone* — the wrong answer, indistinguishable from the
> right one. Stay well inside 1500.

**Expect your quest arrow to disappear for the duration.** That is F24's single-slot behaviour,
not a fault. The task hands the slot back on `sp`.

---

## Run

```bash
/coadump st satnav
```

Pins where you stand and starts recording at 5 Hz. Then, in any order:

| | Manoeuvre | Answers |
|---|---|---|
| **A** | Walk **upstairs**, directly above the pin. Stand still ~5 s. | is `distance` **3D or 2D** |
| **B** | Return to the pin, **stand on it**, spin the camera through a full turn — put the point **behind you**. Pause a beat facing away. | does `distance` **survive going off-screen** |
| **C** | Walk out to the **neighbouring zone**, staying close. Stand still ~5 s. | does the engine **supertrack cross-zone** |

```bash
/coadump sp
/reload
```

Then land it: `addons/menu.bat` → watcher (or `py addons\landing\pull.py watch`).

---

## What the chat line tells you (and what it does not)

```
satnav: N samples, M mapID(s), dist X..Y, screen-invalid P (of which Q kept a distance)
```

- **M = 2** confirms you actually crossed a zone boundary. If it is 1, (C) did not happen.
- **Q vs P** is the whole of (B), read at a glance: `Q == P` means distance survived every
  off-screen sample; `Q == 0` means it died with the screen position — and law 14's
  arrival-wipe cannot be built on it as designed.
- **Nothing here answers (A).** That needs `summary.verticalProbeRow` from the landed record.

## Reading the record

- **(A) 3D vs 2D** — `payload.summary.verticalProbeRow` is the sample with the greatest vertical
  offset while horizontally close. Compare its `sd` against `hd` and against
  `sqrt(hd² + vd²)`:
  - `sd ≈ hd` → **2D**. Law 14's 5 yd `Interact with` tier is unsafe as specified.
  - `sd ≈ sqrt(hd² + vd²)` → **3D**. The tier stands.
- **(B) off-screen** — `samplesScreenInvalid` and `samplesScreenInvalidWithDistance`.
- **(C) cross-zone** — `targetStatesSeen` keyed by `Enum.NavigationState`
  (`0 Invalid · 1 Occluded · 2 InRange · 3 Disabled · 4 InRadius`), read alongside the rows
  where `pm` differs from `pin.mapID`. Also check `tr` (still tracking?) and `gp` on those rows
  — `gp` reports whether the client still holds our position in `SUPER_TRACKED_POSITION`
  (`1` matches our pin · `0` holds something else · `-1` gone), which distinguishes *the engine
  declined* from *the client dropped our intent*.

## Failure tells

| Symptom | Meaning |
|---|---|
| `satnav: aborted - GetCurrentPlayerPosition returned nothing` | not a valid position context; move and retry |
| `showInGameNavigation is OFF` warning | set the CVar, then `sp` and restart the task |
| `[CAPPED]` in the summary | 5,000 samples (~16 min) hit; the run is still valid, just truncated — reported, never silent |
| `tick_errors` present in the record | sampler threw; count is recorded, investigate before trusting the rows |
| chat says `FALLBACK - ladder bypassed` | `SuperTrackerUtil` was missing, so F24's correct entry point was unavailable; treat the run as suspect |
