# The UI test sheet — the specimen standard, and how bench translates to in-game

_Written by the UI specialist at Battlewrath's instruction, 2026-08-23 ("a test sheet for COA devdump…
swatch boards and placement checks so we have basis for translating bench to in-game" — then "Build").
The declaration is `addons/COA_DevDump/sheet_decl.lua`; the diff is `addons/tools/check_sheet.py`.
This page is the reasoning; the declaration is the data and the tool is the machine._

## What it is

**One declaration, two renderers, a machine-emitted diff.** A list of specimens is consumed offline by
`addons/tools/smoke/frames.lua` and in-client by COA_DevDump, and the two results are compared per cell.

A pane we build, screenshot and eyeball is a gallery — it tells you it looked wrong, not by how much or
in which direction. The sheet is the translation layer because the prediction exists **before** the
measurement, so every run reports agreement rather than an impression. That is AP-13's test met
literally: *"give the agents a feedback loop rather than working blind and success being tuned by churn."*

## ★★ The rule that makes it a standard rather than a sample

Battlewrath, 2026-08-23: *"doing it against an active addon only tells you about that addon rather than
a broad insight."*

> **CALIBRATE on the sheet. CHECK our panes with the calibrated model. Never the reverse.**

⚠ The failure this forbids is not sloppiness, it is circularity that reads as success: tune the offline
model against the DungeonRun pane, then declare the pane correct because the model agrees. Nothing in
the output would look wrong.

★ It has a consequence in what already exists. `task_geom` has two sections doing incompatible jobs —
`reference` (four client panels, whichever happened to be open) is an *accidental* standard, and `ours`
(177 of our controls) is the subject under test. **The sheet supersedes `reference`. `ours` stays exactly
as it is, and is worth more for the separation.**

## ⚠⚠ Append-only, and why

A calibration standard whose specimens change is not a standard: every prior run's numbers quietly stop
being comparable, and **nothing would flag it**. Entries may be APPENDED. An entry's meaning never
changes in place; nothing is reordered or removed.

The guard, today: `check_sheet.py` prints a `sha256` fingerprint of the expanded cell set on every run,
so a moved standard is visible in the output and in whichever `UI_LOG` entry cites it. A stricter guard
(a recorded fingerprint that a `--check` compares against) is deliberately **not** built — there is no
evidence yet that anyone has moved it, and the printed fingerprint makes the first breach visible.

## The declaration

Authored Lua, one global, three readers and no parser anywhere:

- **in-client** — COA_DevDump loads it as an ordinary file (⚠ *not in the `.toc` until `task_sheet`
  exists*; a file the addon loads and nothing reads is an invitation to build on half a thing);
- **offline Lua** — `frames.lua` reads the same file;
- **repo tooling** — Python parses it with `Weak Auras/lua_table.py`, the codec-proven parser the
  landing pipeline already uses. Reused, not re-derived.

### Cell kinds

| kind | status | what it settles |
|---|---|---|
| `text` | **built** | a FontString's extent — the one number `F.Unmeasured()` refuses to invent |
| `template` | not built | what the client BUILDS vs what `read_templates.py` sourced from `patch-B.MPQ` |
| `surface` | not built | backdrops, insets, tiling — the smoke README's standing hole |
| `placement` | **sheet two**, his ruling | nested / opposing / negative-offset anchors, checked against the offline resolver |

★ **A specimen earns a cell only where the offline model currently GUESSES.** If `frames.lua` already
knows it from source, it is not a divergence and it does not belong here. That is what keeps the sheet an
instrument rather than a gallery.

⚠ **Placement is sheet two on his word** — after the flat specimens prove the loop, because it needs a
declaration format richer than a flat list and that is the half that turns a two-day tool into a
two-week one.

### The two natures, kept apart

- **Measured cells** — predicted vs actual, machine-checkable, a diff with a number. Fact.
- **Taste cells** — the swatch boards. Whether a backdrop *reads* right is not measurable; the client can
  report a vertex colour and that tells you nothing about whether it works. These exist to be looked at
  and annotated, and the annotation is the registry's input, which is Battlewrath's.

Same pane, same run, two columns in the record. Blurring them lets a measured divergence be argued as a
preference, or a preference ship as a fact.

## ★ The fit is held out

Constants are fitted on the `calibration` strings **only**; the error is reported on the `specimen`
strings, which never touched the fit. Fitting on everything and reporting the residual measures the
fitter, not the model — and "broad insight" is precisely a claim about specimens the calibration never
saw. The two roles in the declaration are that split, not decoration.

## Sheet one, v1 — and why it cost no client time

v1's `text` lists are transcribed from `task_geom.lua`'s own `FONTS` / `CALIBRATION` / `OURS`,
deliberately and exactly. That is what made the loop closeable **against the seven geom captures already
on disk**, with no client run at all — the mechanism got proven before any new measurement existed.

⚠ It leaves **two copies of the specimen list**, this one and `task_geom`'s. The second is to be deleted
when `task_geom` reads the declaration instead. Named rather than done: it changes a shipping capture
task, and the proof did not need it.

## What the first run established

Run `py addons\tools\check_sheet.py`; the numbers below are its output, not transcribed judgement.

- **The client answers text widths on an integer grid**, q = 0.6275280733 UI units, 275/275 shown
  FontString widths on it.
- **The never-shown control width is the only captured value off that grid** — the geom runsheet's
  existing ruling (*calibrate on a SHOWN frame*) reached from a second, independent direction.
- **Offline text is not exact.** Held-out error is per font object, not global: 1 q (0.63 UI units) on
  FRIZQT @ 12 — the workhorse — and 9 q (5.65 UI units) on FRIZQT @ 10.

### Two things the sheet found about itself

★ **The FRIZQT @ 10 residual is a BIAS, not scatter.** The model runs 3–6 q high on nearly every real
label and 9 q low on the longest one. A biased fit means the calibration strings — synthetic repeats and
one pangram — do not represent the letter mix of real labels at that size. ⟶ **The next append is
letter-mix-representative calibration strings.** That needs a capture, since a new string has no client
measurement; it is a proposal, not a build.

⚠ **A contaminating value does not announce itself here.** The first cut of `derive_quantum` fed the
never-shown control width in with the rest. Because any `q/n` also fits a set, one off-grid value simply
drove the search to a 5× finer grid, reported *289/289 on the grid*, and destroyed the finding. It did
not look like an outlier — it looked like a cleaner answer. The fix is structural: derive on the clean
population, **test** the other one.

## What is still open

**q's identity.** `1/q` = 1.5936 device px per returned unit, while `uiScale × screenH/768` = 2.2534 — so
the pixel size the client rasterises at is not the obvious one, and no guess goes in here. Every number
above is conditional on **one** configuration (uiScale 0.85, 3620×2036); all seven captures share it.

★ **One sheet run at a second uiScale settles it**, and settles it for every future cell kind at once: if
q scales with the change it is a device-pixel artefact and the rasterisation size is derivable, after
which *hinted* advances should close the residual; if q holds fixed it is a font-engine constant and
"±N q, marked" is the final answer.

Related: `UI_LOG.md` UL-1 · `ARCHITECT_PROPOSALS.md` AP-13 · `geom_probe_runsheet.md` (the capture this
was proven against) · `addons/tools/smoke/README.md` (the divergence this row belongs to).
