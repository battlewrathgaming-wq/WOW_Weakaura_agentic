# UI_LOG — the UI specialist's outcomes and reasoning

_Opened 2026-08-23 when Battlewrath stood the seat up ("Yes. Proceed."). Same form as `ARCHITECT_LOG.md`:
one entry per act or decision — the question · the outcome · the reasoning · what it cites · where it LANDED ·
whose word. The log never carries a ruling's body. Read newest first. **The seat's guide is `UI_SEAT.md`;
its #0 is `ARCHITECT_PROPOSALS.md` AP-13 until the registry exists and becomes #0 itself.**_

    ENTRY FORM    UL-N · date · from (conversation | ARCHITECT_INBOX AI-N | Reconcile_inbox RI-N) ·
                  QUESTION · OUTCOME · REASONING · CITES · LANDED IN · WORD

---

## UL-1 · 2026-08-23 · the width check answered off the shelf, and the sheet became the instrument
**QUESTION** — UL-0 act 1: is offline text "exact" or "±N px, marked"? And then, from him mid-act:
should a **test sheet** in COA_DevDump carry it instead of a one-off run?

**OUTCOME, four parts.**
1. **The client half was already on disk.** UL-0 asks for `GetStringWidth` on ~10 strings.
   `task_geom.lua` has measured **26 strings × 11 font objects** since 2026-08-15 and **seven live
   runs** are in `addons/landing/records/`, all agreeing. No client run was needed for act 1.
2. **The answer is ±N q, MARKED, and N is per font object, not global.** Held-out error: **1 q =
   0.63 UI units on FRIZQT @ 12** (GameFontNormal/Highlight/Red/Disable — the workhorse) up to
   **9 q = 5.65 UI units on FRIZQT @ 10**. Emitted by `check_sheet.py`, not transcribed.
3. **★ Client text widths sit on an integer grid**, q = 0.6275280733 UI units — 275/275 shown
   FontString widths on it. **The never-shown control width is the only captured value off it**,
   which is the geom runsheet's existing *calibrate on a SHOWN frame* ruling reached from a second,
   independent direction.
4. **The sheet supersedes the one-off run**, and `task_geom`'s `reference` section with it.

**REASONING** — his: *"doing it against an active addon only tells you about that addon rather than
a broad insight."* ⟶ the directional rule now in the spec: **calibrate on the sheet, check our panes
with the calibrated model, never the reverse** — the reverse is circular and would read as success.
⟶ and the standard must be **append-only**, or every prior run's numbers stop being comparable with
nothing to flag it. The fit is **held out** (constants from the `calibration` strings, error reported
on the `specimen` strings) because fitting on everything measures the fitter, not the model.

⚠ **Two things the sheet found about itself, both worth more than the verdict.** The FRIZQT @ 10
residual is a **bias, not scatter** — 3–6 q high on nearly every real label, 9 q low on the longest —
so the calibration strings do not represent the letter mix of real labels at that size; the next
append is letter-mix-representative strings, which needs a capture and so is a proposal, not a build.
And **a contaminating value did not announce itself**: the first `derive_quantum` fed the never-shown
width in with the rest, and because any `q/n` also fits a set it silently drove the search to a 5×
finer grid and reported *289/289 on the grid*. It looked like a cleaner answer, not an outlier.

**STILL OPEN, one thing** — q's identity. `1/q` = 1.5936 device px per returned unit while
`uiScale × screenH/768` = 2.2534, so the client's rasterisation pixel size is not the obvious one and
no guess goes here. All seven captures share **one** configuration (uiScale 0.85, 3620×2036), so every
number above is conditional on it. ★ One sheet run at a second uiScale separates a device-pixel
artefact from a font-engine constant — and settles it for every future cell kind at once.

**CITES** — AP-13 (2)(5) · `geom_probe_runsheet.md` Run 1 · `smoke/README.md` (the FontString hole) ·
`prior_art_ui_tooling_2026-08-23.md` §(f) *font metrics offline: nobody has them*.

**LANDED IN** — `addons/COA_DevDump/sheet_decl.lua` (the standard, v1) · `addons/tools/check_sheet.py`
(the diff) · `addons/planning/ui_sheet_spec.md` (the reasoning) · `UI_SEAT.md` (the boundary, below).

**WORD** — Battlewrath, 2026-08-23: the sheet, *"Yes. Once proven we can build on it"*; placement as
sheet two; then *"Build."* ★ And the boundary refined in the same breath: *"Pane in the broad context
is against an active addon. You're free to work on Devdump as part of calibration and knowledge
forming."* ⟶ **this seat may build in COA_DevDump.** Recorded in `UI_SEAT.md`; the panes of a shipping
addon remain the Addon creator's.

---

## UL-0 · 2026-08-23 · the seat opened — first three acts, in order (the architect's, from AP-13; Battlewrath: "Yes")
1. **The width check.** `COA_DevDump task_geom` `GetStringWidth` on ~10 strings vs the offline FreeType widths
   (client font from `Data/enUS/locale-enUS.MPQ`, 12px: "Dungeon Run" = 77). Decides whether offline text is
   "exact" or "±N px, marked". Lands as a row in the smoke README's divergence table either way.
2. **The capture widget** in `COA_DevDump`: hover a control → its measured facts (inset · stack · inline ·
   size parts · type role · surface · border) → pick one → Battlewrath types the why → one record =
   bucket · tier · job · why (+ M3 category on controls). Source vocabulary: `audit/prior_art_ui_vocabulary_2026-08-23.md`.
3. **The census** over the 254 launcher addons, captured geometry first, source second. The registry is
   curated FROM it, with him — never authored cold.
Nothing here is built yet; each act is the Addon creator's to land against this seat's spec, or this seat's
own where it is a tool (`addons/tools/`), on the word.
