# UI_LOG — the UI specialist's outcomes and reasoning

_Opened 2026-08-23 when Battlewrath stood the seat up ("Yes. Proceed."). Same form as `ARCHITECT_LOG.md`:
one entry per act or decision — the question · the outcome · the reasoning · what it cites · where it LANDED ·
whose word. The log never carries a ruling's body. Read newest first. **The seat's guide is `UI_SEAT.md`;
its #0 is `ARCHITECT_PROPOSALS.md` AP-13 until the registry exists and becomes #0 itself.**_

    ENTRY FORM    UL-N · date · from (conversation | ARCHITECT_INBOX AI-N | Reconcile_inbox RI-N) ·
                  QUESTION · OUTCOME · REASONING · CITES · LANDED IN · WORD

---

## UL-4 · 2026-08-23 · the picture is not the box — sheet three, and a run card that had been right for a day
**QUESTION** — his: *"The issue was the surrounding art / materials that comes with the UI. Like the
drop down selector's down arrow."* And the method with it: *"build concept out clean and extract
useful comments, over editing in field… reasoning comes from collating and collecting to stable
surfaces."*

**OUTCOME** — the lesson was not in commit history as a search problem. It is **§103, "the neighbour,
not the edge"** (2026-08-15), and its durable form has been in `COA_DungeonRun/layout.lua:108-131`
ever since — in the code, where you are standing. The rule, his bench's words:

> *a rect check UNDER-REPORTS a dropdown by design, and a pane can look wrong exactly where the
> arithmetic says it is fine*

`UIDropDownMenu_SetWidth(dd, w)` gives FIELD `w`, TEXT `w-25`, ART `w+50` — and the arrow that
reacts to a click lives out in that Right texture, outside the frame you sized. Vertically the three
textures are 64 tall on a frame declared 32, anchored at y=+17.

**★ IT ALSO CLOSES THE PLAY BUTTON.** The promoter asked 200, read it as *200 wide*, put a button at
208 — inside the 250 of art. The geometry run measured that button as comfortably INSIDE its pane
and filed the cause as unknown, because **every instrument we own compares rects.**

**⚠⚠ AND `geom_probe_runsheet.md` STILL SAID UNKNOWN — stale by one commit, for eight days.** §102.1
wrote *"no third guess goes in here until something measures it"*; §103 answered it the next commit,
and it even listed *"art beyond the frame edge"* as one of three candidates. ★ That page is what
someone reads **before spending a run**, so a dead question sitting there costs a capture. Corrected
by POINTER, not rewrite (his steer): the dead reasoning stays, because it is the record of *why the
answer was hard to see*.

**WHAT IT NAMES IN MY OWN WORK** — sheet two measured `frame:GetWidth()`. Every number in that table
is what the layout uses and **none of it is what the eye sees**. `Layout.ART = { dropdown = { dw =
50, h = 64, dy = 17 } }` is one entry, hand-measured, for one template.

**LANDED IN** — `concepts/art-and-rect.md` (the concept, built out clean: what it is · the closed
list · the case that paid for it · where it is ruled · what is owed, derived not read) ·
`sheet_decl.lua` kind `art` (13 subjects: 6 stock templates + 7 AceGUI widgets) · `task_sheet.lua`
(region union, VISIBLE regions only, hidden ones COUNTED — "none were hidden" and "we did not look"
are different facts) · `check_sheet.py --art` (per EDGE, because the dropdown is asymmetric and one
"art is bigger" number would hide which neighbour it eats) · the run card's pointer.

**⚠ DELIBERATELY NOT SETTLED**, so nobody reads a decision into the concept home: whether
`frames.lua` should carry art at all, or whether art stays a client-measured table the offline
resolver merely cites. The offline resolver reports overlaps and overhangs in RECTS only, so this
entire class is invisible to it — named as a gap, not closed.

**WORD** — Battlewrath, 2026-08-23, as quoted; *"Proceed how you see fit."*

---

## UL-3 · 2026-08-23 · the scaling half was community knowledge, and I derived it anyway
**QUESTION** — his, and it is a correction I earned: *"WoW is 18 years old if not older. I am sure our
question is a known answer in the addon community."*

**OUTCOME — he is right about the half that mattered most, and the record now starts there.**
1 UI unit = 1/768 of the screen height × a ratio; pixel-perfect scale = `768/vRes`; the game clamps
`uiScale` at 0.64 (Warcraft Wiki, *UI scaling*). And **ElvUI's `E.mult`, which is installed on this very
client**, simplifies to **`768/(vRes × scale)` — one DEVICE PIXEL expressed in UI units**. That is the
whole scale story, solved, published, and sitting in `ElvUI/Core/PixelPerfect.lua` on disk.

**Restated on top of it, our one added term**, measured over **nine** configurations (5 resolutions,
3 aspect ratios, 4 UI scales; worst disagreement **1.0e-07**):

> a FontString width is **quantised to `hRes/2560` device pixels** — equivalently
> `GetScreenWidth()/2560` UI units, equivalently `E.mult × hRes/2560`.

⚠ At a 2560-wide display that is exactly one device pixel. That is plausibly the constant's origin and
it is an **inference**, marked as one — nothing in FrameXML carries a 2560, and the engine is closed.

**⚠⚠ THE FAILURE, WHICH IS THE POINT OF THIS ENTRY.** Prior art did not merely exist — **it was already
on my own shelf and I had read it.** `audit/prior_art_ui_tooling_2026-08-23.md` §5 carries `E.mult`, the
rounding formula and `ratio = 768/screenheight` verbatim; I read that audit at boot, cited it in UL-1's
own basis, and then spent nine captures deriving the scale relationship from scratch — reporting `1/q =
1.5936 vs uiScale × screenH/768 = 2.2534` as an open mystery when the missing term was a *width* one and
the framework for seeing that was in the file. ★ **The law already on the spine is
[[the-basis-includes-the-other-benches]]; what it lacked was a trigger.** A named open question is
exactly the moment to re-read the audit, and "I read it at boot" is not the same as reaching for it when
the question arrives.

★ **And the cost was not zero.** Anchoring on `E.mult` first would have expressed q in DEVICE PIXELS
immediately, where the answer is `hRes/2560` and visible on the **second** configuration rather than the
ninth. The sweep would still have been worth running — nine configurations is what makes 1.0e-07 a
result rather than a coincidence — but it would have been confirmation, not search.

⚠ **What is genuinely NOT in the community record**, checked rather than assumed: two searches plus the
wiki page return nothing on FontString width quantisation, and the commissioned tooling audit
independently filed *"font metrics offline: nobody has them — not found"*. So the `hRes/2560` term looks
like ours. ★ That is a claim about where I looked, not about the world.

**ALSO SETTLED THIS PASS** — `k` (quanta per em) depends on **uiScale alone**: identical to four decimals
across four resolutions and three aspect ratios at scale 0.64, and across three at scale 1.00. The
earlier "1440×1080 is an outlier" reading was mine and is **withdrawn** — `em_UI` looked unstable only
because it is `k × q` and q carries the resolution. ⚠⚠ `k` is NOT smooth in scale: 0.64→0.65 jumps
14.608→15.853 with non-overlapping plateaus, so an unmeasured scale must be **measured, never
interpolated**. ⚠ `c` still wobbles ±2 quanta between resolutions at one scale; fit artefact vs client
fact is unseparated.

**CITES** — warcraft.wiki.gg *UI scaling* · installed `ElvUI/Core/PixelPerfect.lua` ·
`audit/prior_art_ui_tooling_2026-08-23.md` §5 and §(f) · nine `*__sheet.json` records.

**LANDED IN** — `operations/ROUTER.md` (the row now leads with the community formula and cites it) ·
`ui_sheet_spec.md` · this entry.

**WORD** — Battlewrath, 2026-08-23, as quoted. Taken as a standing correction, not a one-off.

---

## UL-2 · 2026-08-23 · the sheet got a spawner, and the sweep got a command he does not have to remember
**QUESTION** — from conversation: *"If we have the sheet spawner and the sheet reader, and the landed
file (on /reload) on the bench tool - watcher pickup into inbox. Then I'll sweep through a few UI
resolutions."* ⟶ then the requirement that shaped it: *"Spawner and read command / dispatch instruction
in-game. **I get lost writing the test commands manually.**"*

**OUTCOME** — `/coadump r sheet`, **one command, no arguments, the same at every setting.** The run
reads the configuration off the client rather than being told it, so a sweep is two lines repeated:
`/coadump r sheet` · `/reload`. `check_sheet.py` prints those two lines as its own last output, so the
dispatch instruction lives in the tool and the run card is the backup rather than the mechanism.

**REASONING** — [[plays-by-flattening-decisions]]: the load to remove is not typing, it is *deciding
what to type*. An argument he has to get right at each of four resolutions is four chances to record a
configuration under the wrong label, and the label is the whole experiment.

★ **The sheet is SHOWN while it is measured, and that is correctness rather than presentation.** UL-1
measured the never-shown control width as the only captured value off the client's grid — 1.7% out,
the worst kind of wrong. So the host is parented, positioned and visible, and the record says so.
★ Being visible is also the taste half: eleven swatch rows to look at, which no machine can judge.

⚠ **Two things checked rather than assumed, either of which would have failed silently mid-sweep.**
`pull.py` has **no task whitelist** — it keys on the SavedVariables source, so `sheet` lands as
`<runId>__sheet.json` with no change to the watcher. And **agreement is now checked WITHIN a
configuration, never across one**: the first reader compared every run to every other and would have
reported 275 disagreements the moment the sweep began — the alarm firing on the data it exists to
collect. Both branches walked against synthetic records in the scratchpad before he runs anything:
q-fixed, q-moved, and same-configuration disagreement all behave (the last refuses to model, exit 2).

**WHAT THE SWEEP DECIDES** — q moves with the configuration ⟶ device-pixel artefact, rasterisation
size derivable, hinted advances should close the residual. q fixed ⟶ font-engine constant and
"±N q, marked" is final. ★ Either closes it for every future cell kind at once. ⚠ Vary uiScale AND
resolution, not one at a time — they enter the suspected mapping as a product.

**LANDED IN** — `addons/COA_DevDump/task_sheet.lua` + `.toc` · `addons/tools/check_sheet.py` (configs,
per-configuration q, dispatch line) · `addons/planning/sheet_runsheet.md` (the run card).

**WORD** — Battlewrath, 2026-08-23, as above. ⚠ Nothing is deployed or captured yet: `deploy.py` needs
the game closed and the client restarted (new files, not a `/reload`), and both are his.

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
