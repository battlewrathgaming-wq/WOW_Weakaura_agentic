# `/coadump r api` — the run card

_Measures whether the CLIENT behaves the way the offline test harness MODELS it, and matrices the
read-only API surface against bad inputs. **Read-only. It writes nothing to your client.**_

## Why this run exists

`addons/tools/smoke/harness.lua` teaches the offline stubs to behave like the client — `SetText`
fires `OnTextChanged`, `Show`/`Hide` fire on transitions, `SetTexture` resets `TexCoord`.

⚠ **Every one of those claims was reasoned, not measured.** The whole test suite runs against a model
nobody has ever checked against the thing it models. If one claim is wrong, the suite has been green
on a fiction — and §77's dead ticks and §77.2's dead toggle are both proof that green is not the same
as correct.

★ This is the instrument that checks. **A disagreement is worth more than a clean sheet.**

## Before

```
py addons\deploy.py
```

Then a **full client restart** — new files, not a `/reload`.

## Where to run it

**Standing inside Shadowfang Keep, on a lower floor.** Several of the probed calls are
zone-dependent (`GetMapInfo`, `GetCurrentMapDungeonLevel`, `GetInstanceInfo`, `GetDifficultyInfo`),
and a run taken in a city answers a much thinner set of questions. The sheet records where it was
taken, so a city run is not *wrong* — it just says less.

★ It pairs with the route walk that is still outstanding: arm a route, walk it, then run this before
you leave.

## The run

```
/coadump r api
```

One line comes back. **It is by exception** — the number that matters is the first one:

```
api: 5 behaviour(s), 0 disagree; 176 call(s), 12 threw, 4 missing
```

- **`disagree`** — behaviours where the client did **not** do what `harness.lua` claims. **Any
  non-zero here is the finding**, and it means an offline test has been passing on a wrong premise.
- **`threw`** — calls that errored rather than returning nil. Not a fault; it is the answer to *"do
  I need a `pcall` here or is a nil-check enough?"*, which I have guessed at more than once.
- **`missing`** — names absent from `_G` on this fork. Also not a fault, and one of the more useful
  columns: it tells us what this fork does not have.

Then:

```
/reload
```

to flush the mailbox, and the watcher lands it. `devdump` is a **tracked** source, so the record
commits.

## After

The landed record is `addons/landing/records/<runId>__api.json`, carrying:

| block | what it holds |
|---|---|
| `where` | zone, subzone, mapID, floor, in-instance — so the sheet can be read months later |
| `behaviours` | one row per modelled behaviour: `claim` · `observed` · `agrees` |
| `calls` | one row per function × input: `ok` · return arity and types, **or the error text** |
| `verdict` | the three counts from the chat line |

⚠ **No reader tool is built yet, deliberately.** Writing one against a record shape nobody has seen
would be guessing at the output of the instrument that exists to stop us guessing. Once there is a
real sheet, the reader gets built from it — the same order capture and the promoter were built in.

## ⚠ What this run does NOT cover

Named so the sheet is not over-read (the full list is `addons/tools/smoke/README.md`):

- **Nothing in the census's PUSH list is probed.** `SetCVar`, `SuperTrackerUtil.*`, `SetMapByID`,
  `PlaySound` all have real side effects, and a diagnostic that changes the machine it is diagnosing
  is not a diagnostic. Probing those would be a separate task with each call's restore written first.
- **Frames are 1×1 and positioned off-screen** — shown, so events actually fire, but rendering
  nothing. Nothing here says anything about layering or hit-testing. ⚠ v1 hid them instead, which is
  what killed run 1.
- **Single sample.** These are structural questions, not statistical ones, but a behaviour that
  depends on load order or on another addon would not show in one run.


---

## Run 1 — 2026-08-14, Shadowfang Keep floor 1

**`api: 5 behaviour(s), 4 disagree; 176 call(s), 26 threw, 0 missing`**

⚠ **The four disagreements were false.** Every counter in the run read zero, including the one that
"agreed" — and in a run where nothing fires, a claim of ABSENCE (`SetChecked does not fire OnClick`)
passes for entirely the wrong reason. **0 of 5 informative, not 4 findings.**

★ Cause was mine: every experiment was parented to a HIDDEN host for safety. A child of a hidden
parent never becomes visible, so `Show()` never transitioned and `OnShow` never fired — which killed
the transitions test and the `SetScript`-replaces test that rides on it. The `TexCoord` row was
inconclusive for a different reason: nothing checked that the second `SetTexture` had taken, so
*"the crop survived"* and *"the texture never changed"* were the same reading.

★★★ **The instrument could not tell "the client disagrees" from "my experiment never ran", and
reported the second as the first, in red, four times.**

### What changed (v2)

| | |
|---|---|
| **every experiment carries a CONTROL** | a measurement that must succeed whatever the claim turns out to be. Control false → the row is **`inconclusive`**, never `disagree` |
| **a claim of absence must prove its detector** | `SetChecked` now **clicks the button first**. Absence is unfalsifiable until something has been shown to fire |
| **the run-level catch-all** | if not one control fired anywhere, the summary leads with **`APPARATUS DEAD`** — a dead apparatus outranks a disagreement, because a disagreement measured by a dead apparatus is not one |
| the apparatus | parented to `UIParent`, positioned off-screen, never hidden. A 1×1 frame with no textures renders nothing anyway, so the old "safety" bought nothing and cost three findings |
| `TexCoord` | verifies `GetTexture()` actually changed, and that the crop took, before judging |
| **drift** | `addons/tools/check_harness.py` pairs `harness.lua`'s `-- BEHAVIOUR:` markers against the probe's names, so the model and the measurement cannot silently cover different sets |

### ✅ What run 1 DID establish — the calls half worked

**Six functions throw rather than returning nil**, which guard clauses had been guessing at:

| | |
|---|---|
| `GetPlayerMapPosition` · `UnitName` · `UnitClass` · `UnitIsGhost` · `GetCVar` | `Usage: ...` on nil / no args / wrong type |
| `GetDifficultyInfo` | throws from **inside** `GlobalFunctions.lua:263` — *"attempt to concatenate local"*. The client's own function does not validate |
| `GetAddOnMetadata` | throws on **every** input tried; it needs two args. Incidentally: *"AddOn index must be in the range of 1 to 116"* |

★ So `local n = UnitName(u); if not n then` never reaches its check — it errors first.

Incidentals from inside the instance, all measured rather than assumed:

- `IsInInstance` returns **`1`, not `true`** (plus `"party"`). The driver handles it; **the offline stub returns `true`**, so that is a live model divergence.
- `GetCurrentMapContinent` = **-1**, `GetCurrentMapZone` = **0** inside an instance.
- `GetCurrentMapAreaID` = **765** while the internal mapID is **33** — `maps/worldmap` M8, now measured.
- `GetNumDungeonMapLevels` = **7**, matching the seven SFK floors.
