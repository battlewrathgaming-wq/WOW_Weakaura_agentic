# UI FINDINGS — Ace3 in house, and the client's own XML templates

_Addons bench, 2026-08-18 (§351). Filed for the Analyst/designer side against
`driver_ui_scope.md` §3 (the fork) and §5 (what must be true before any pane is re-laid).
**Everything below is measured, not argued** — the tools that produced each number are named
so any line can be re-run._

---

## 0. THE HEADLINE

**`PerformLayout` RAN, under our own Lua 5.1 harness, on both Ace3 revisions.**

`driver_ui_scope.md` §3's A′ rests on one claim: *"AceGUI is pure Lua over the frame API;
branch Ace3 INTO the harness and its `PerformLayout` runs under lua51."* That was a
prediction with a named cost (*"STUB-SURFACE DEPTH… templates"*). **It is now demonstrated,
and the cost was the templates exactly as predicted — and they turned out to be readable
rather than modellable.**

    revision        widgets built   PerformLayout   templates unresolved
    wotlk-r960          9 / 10           RAN                0
    modern-r1403       10 / 10           RAN                0

---

## 1. BOTH REVISIONS ARE IN HOUSE

From upstream `WoWUIDev/Ace3` (BSD, Ace3 Development Team), under `dependencies/Ace3/` —
212 files, 1.8 MB. The repo carries 49 release tags; these two were picked by date:

    wotlk-r960      2010-07-20    AceGUI-3.0 rev 33   after 3.3.5 shipped, before the Cata prepatch
    modern-r1403    2026-08-12    AceGUI-3.0 rev 41   latest

**★ The client corroborates the WotLK pick exactly.** AceGUI on this client is **rev 33** —
Bartender4, Recount, Skada, PlateBuffs and ShadowedUF_Options all ship it (Omen is on 30).
`wotlk-r960` **is** rev 33: the upstream WotLK revision is the same one the client's working
addons run.

⚠ **Vendored copies are the CHECK, never the SOURCE.** Battlewrath's ruling, and it holds:
adopting Bartender4's copy would be adopting Bartender4's trims, patches and pinned revision —
someone else's answer to a question we have not asked. We took upstream whole and used the
vendored copies only to confirm the revision runs here.

---

## 2. TERM MATCH — does this fork answer everything Ace asks for?

`addons/tools/match_api_terms.py` (new). The probe records every global and frame method
AceGUI actually reaches for at load, construction and layout; the matcher asks four corpora
whether this fork has been seen using them. **The corpora are ranked and never summed:**

    ROUTER      operations/ROUTER.md — a MEASURED fact about this fork; outranks everything
    CENSUS      our own capture of the client's `_G` (globals only — a frame method is not in _G)
    OURS        code we wrote and shipped here (88 files; 336 ref/vendored set aside)
    ADDON       third-party addon code on this client (1936 files, 423 vendored)
    VENDORED    third-party LIBRARY code — kept separate because it is circular: Bartender4's
                own AceGUI calling a method only tells us what AceGUI calls

**Result:**

    wotlk-r960     48 names   ROUTER 3 · CENSUS 17 · OURS 20 · ADDON 8      0 vendored-only   0 NO MATCH
    modern-r1403   50 names   ROUTER 2 · CENSUS 16 · OURS 21 · ADDON 10     1 vendored-only   0 NO MATCH

**★ r960's entire API surface is independently attested on this fork.** Nothing it touches
is unknown here.

**The diff is the evidence for a base.** Modern reaches four names r960 does not, all
retail-era:

    WOW_PROJECT_ID          ADDON, 1 file      version constants modern Ace3 branches on
    WOW_PROJECT_MAINLINE    ADDON, 1 file
    securecallfunction      CENSUS             exists here
    ChatFrameUtil           vendored-only      ★ the ONLY name across both trees with no
                                               independent attestation on this fork

⚠ This is not "modern will not run" — it built 10/10 widgets, and a nil `WOW_PROJECT_ID` is
what those branches exist to handle. What is measured: **r960 asks this client for nothing it
has not been seen answering; modern asks for four things beyond that, one unattested.**

⚠⚠ **The tool proves matches and can never prove absence**, and it says so on its own output.
ROUTER:75 is the standing reason: *"`C_Timer` enumerates as an EMPTY table in the 51,855-global
census, so a name search finds nothing while it works perfectly — a name search proving absence
proves nothing."*

---

## 3. ★★★ THE CLIENT'S OWN FRAME TEMPLATES ARE READABLE

**This is the finding with the widest reach, and it started as a challenge from Battlewrath
against a wrong claim of mine.**

`Interface\**\*.xml` lives in the MPQ chain and `mpyq` reads it. `addons/tools/read_templates.py`
(new) pulls it out and emits a Lua table the harness builds against:

    archives          patch-B.MPQ, patch-X.MPQ
    parsed            312 XML files
    templates         1209 virtual definitions
    output            addons/staging/framexml_templates.lua   (gitignored, REGENERATED)

⚠ **Read-only on the client throughout.** The archive is opened for reading; nothing is ever
written under `F:\games`. The output is Blizzard's content, so it is a build input we re-make
on demand rather than an artifact we carry.

**What a template supplies is exactly what was missing:** an explicit `<Size><AbsDimension>`,
and named child regions the widget looks up by convention. `UIPanelButtonTemplate`'s
`<ButtonText name="$parentText"/>` **is** AceGUI Button's missing `GetFontString()`;
`UIPanelButtonTemplate2`'s `$parentLeft/Middle/Right` at `40x22` **is** its DropDown's missing
`middle`.

    UIPanelButtonTemplate            1 region
    UIPanelButtonTemplate2           4 regions, 40x22
    InputBoxTemplate                 3 regions
    UIDropDownMenuTemplate           5 regions, 40x32
    UICheckButtonTemplate            1 region,  32x32
    OptionsFrameTabButtonTemplate    7 regions, 115x24
    UIPanelCloseButton               0 regions

**★ THE TEMPLATES ARE READ, NEVER MODELLED.** A hand-written `UIPanelButtonTemplate` would be
a creator dialect ([[source-as-truth-no-creator-dialect]]) — right until Blizzard's numbers and
ours disagree, with nothing to notice when they do.

### ⚠ THIS CLIENT'S UI IS PARTLY MODERNISED, AND IT MATTERS

`Interface\FrameXML\FrameXML.toc` (344 entries, read straight out of patch-B) pulls
`..\SharedXML\UIDropDownMenu.xml`, `..\SharedXML\FilterDropDown.xml` and
`..\SharedXML\ScrollableDropDown.xml`. **The dropdown machinery is retail-shaped and lives in
`SharedXML`, not `FrameXML`.** Anything reasoning about this client's UI from stock-3.3.5
knowledge will be wrong in that region.

---

## 4. WHAT THIS CHANGES FOR OUR OWN CODE, BEFORE ANY ACE DECISION

`addons/tools/smoke/frames.lua` — the offline frame model — **has been dropping the fourth
argument to `CreateFrame` since it was written.** Its own header explains why nobody noticed:

> *"WoW UI Designer had to resolve XML template inheritance, pull textures out of the MPQs, and
> host an interpreter. We have none of that: `COA_DungeonRun` is fourteen `.lua` files and zero
> XML."*

★ **True about our files and wrong about our frames.** `object.lua` builds:

    26  UIPanelButtonTemplate
    12  InputBoxTemplate
     8  UIDropDownMenuTemplate
     8  UICheckButtonTemplate

**54 templated controls, every one measured offline as a sizeless box.** The overlap checker
has never seen a single one at its true size. `F.New` now applies the template — size, `$parent`
child regions, `_G` registration, `GetFontString()` — and reports any template it cannot
resolve rather than silently sizing to nothing.

### A9.6 is TWO sites, and the second is the more useful find

    1  addons/staging/client_rects.lua     a probe capture from 2026-08-15 22:11, containing
                                           11 controls (38 declared today) and `object.ramp` —
                                           a control DELETED in A2.6. §104 made the pane 600
                                           tall at 22:33, 22 minutes after the capture.
                                           → DELETED. `check_rects` now says "no client rects
                                             yet" instead of reporting on a pane that no
                                             longer exists.

    2  smoke_dungeonrunpromoter.lua:1681   `local PANE_W, PANE_H = 240, 330`, under a comment
                                           reading *"THE PANE'S REAL SIZE, read from
                                           object.lua:397 rather than assumed."*
                                           → now READS the numbers out of `object.lua` at run
                                             time and asserts loudly if it cannot.

★ **The second is worth naming as a class: a claim of PROVENANCE that outlived its fact.** It
was true when written. §104 moved the pane and the sentence stayed, and a comment asserting
"read from source" is worse than a bare constant — **it tells the next reader not to check.**
Every "no overlaps" that block printed since §104 was computed on a canvas 270px shorter than
the pane, so a control below `y=-330` could not be reported as outside.

---

## 5. ⚠ CORRECTIONS TO THE RECORD — claims of mine that measurement refuted

_Filed together rather than scattered, because the pattern is one thing: **a name search
proving absence proves nothing**, and I made that error four times in one session._

    "C_Timer doesn't exist on 3.3.5"        WRONG. ROUTER:75 records it as a genuine Ascension
                                            global, in use since COA_GuardianPlates v3.5.5. I
                                            asserted a client behaviour without reading the
                                            file that governs client facts (governing #8).
    "SetDesaturation is a client rename"     WRONG. The client corpus uses `SetDesaturated` in
                                            54 files and `SetDesaturation` in 12. Both exist.
    "FrameXML isn't on disk, it's in the     HALF WRONG, and Battlewrath challenged it. It IS
     MPQ, so templates must be modelled"     in the MPQ — and the MPQ is readable.
    "UIDropDownMenuTemplate is MISSING"      WRONG. It is in `..\SharedXML\`. I scanned
                                            `Interface\FrameXML\` only. The toc is the
                                            manifest; guessing the folder from the name is
                                            what "lost" it.
    "the unreadable archives don't carry     UNFOUNDED AS STATED. Four have no listfile, so "0
     FrameXML"                               FrameXML" meant COULD NOT LOOK. ★ An MPQ hashes
                                            filenames, so `read_file(name)` works without a
                                            listfile — re-probed BY NAME, and FrameXML really
                                            is only in patch-B. (`patch-P.mpq` is encrypted and
                                            remains unreadable; it does not answer to the four
                                            FrameXML paths probed.)

**None of these changed a decision** — they were caught before anything was built on them —
but three of the four were corrected by Battlewrath rather than by a tool, which is the
argument for `match_api_terms.py` existing at all.

---

## 6. WHAT IS STILL UNMEASURED — the text-metrics boundary

An offline layout checker can only claim what it can compute, and it cannot compute
`GetStringWidth` on a font we do not have. §3 calls this a permanent hole **in every option**,
B and C included — correct, but "hole" is the wrong shape, and templates just shrank it:
most regions now carry an explicit `AbsDimension` from source, so measurement only matters
where a FontString auto-sizes.

**★ The boundary is measurable, mechanically:**

> Run `PerformLayout` with a stubbed `GetStringWidth`. **Change the stub and re-run.** Every
> rect that does not move is genuinely verified offline. Every rect that moves is in the blind
> spot — **by name.**

That yields a *list* rather than a caveat: *"offline geometry verifies these N rects and cannot
speak for these M."* A checker that knows its own reach is worth more than one that reports
confidently on everything — and it applies to B and C identically, so it is not an Ace
question.

---

## 7. OPEN — for the designer, not settled at the bench

    Q1  SHIP-WITH-THE-ADDON OR HARNESS-ONLY? Asked earlier, still open, and it is the
        load-bearing one. `driver_ui_scope.md` does not say. Branching Ace3 into the emulation
        and shipping it inside COA_DungeonRun are two different commitments.
    Q2  WHICH REVISION IS THE LITE BUILD'S BASE? Evidence favours r960 — matching revision,
        fully attested surface, no retail-era constants. Modern's advantage is that it is
        maintained. Bench read: r960; overturnable.
    Q3  DOES THE LITE BUILD TAKE WIDGETS OR THE WHOLE THING? §4 names what the panes need
        (tab group, label, editbox, checkbox, dropdown, slider). The rest is carriage.
    Q4  A9.6's WORDING. The criterion says *"the checker's canvas equals the shipped pane size
        (read from one place, not typed twice)"*. That described one mechanism; there were two
        sites and neither matched the description. Both are fixed; the row should say what it
        now guards.
    Q5  IS THE TEXT-METRICS SWEEP (§6) WANTED NOW, or after the overhaul's shape is set?

---

## 8. STATE — what is on disk, and what runs

    NEW TOOLS
      addons/tools/read_templates.py     MPQ → framexml_templates.lua (staging, regenerated)
      addons/tools/match_api_terms.py    a name list → four corpora, ranked, never summed

    CHANGED
      addons/tools/smoke/frames.lua                 F.New takes a TEMPLATE; loud on unresolved
      addons/tools/smoke/smoke_dungeonrunpromoter   canvas read from object.lua, not typed

    DELETED
      addons/staging/client_rects.lua    the 2026-08-15 capture. Regenerate with the in-client
                                         probe (`/coadump r geom` → `read_geom.py`) whenever a
                                         live comparison is wanted — that run is Battlewrath's,
                                         never the bench's.

    LANDED
      dependencies/Ace3/wotlk-r960       212 files across both revisions
      dependencies/Ace3/modern-r1403

    GREEN
      19/19 smokes · check_interface 105/105 registered, 6 surfaces reconcile · 6/6 A1
      mutations bite on their own message

    KNOWN, SMALL, OURS
      AceGUI DropDown wants a region size the harness does not set yet (`compare number with
      nil`); r960's CheckBox wants `SetDesaturation` stubbed — real on this client (§5),
      simply absent from the harness.

---
_Tools named above reproduce every number here. The audits in this folder are the evidence
base; this file is the bench's measured addition to them._

---

# ★ FINDINGS LOG — appended per leg, newest last

_Battlewrath, 2026-08-18: footer findings here as they come. The `driver_ui_proposition.md`
that carried the last set has left (its 13 items folded into A10.x), so this relay is their
home. Each entry is measured; the tool that produced it is named._

## §354 · P1 — the client's own FrameXML Lua in the harness

**F1 · THIS CLIENT'S `LibStub` IS FORK-NATIVE, AND IT CAN REFUSE OUR COPY.**
`Interface\FrameXML\LibStub.lua`, marked *"Version 3 = Ascension Exclusive"*. `NewLibrary`
and `GetLibrary` both call `LoadLibrary(major)` when `IsLibraryLoaded(major)` is false — **the
client can serve a library from its own store** — and `NewAscensionLibrary` sets
`minors[major] = math.huge`, after which an addon's own copy of that major is refused forever.
Both globals are real here (our `_G` census); **ROUTER records neither**.

⚠ **Bearing on A10.1b:** *"shipped in Dungeon Run (own copy)"* may not be the copy that RUNS.
If Ascension serves `AceGUI-3.0`, our `NewLibrary` returns nil, our file bails, and every line
we write runs against a version nobody measured or chose. The harness stubs
`IsLibraryLoaded → false`, which models *"Ascension serves nothing"* — the **optimistic** case,
declared as a choice and reported as a blind spot.
★ **Only the client answers this.** One command:
`/run for k in pairs(LibStub.libs) do print(k) end` and `/dump IsLibraryLoaded("AceGUI-3.0")`.

**F2 · OUR EXTRACTION'S HOLES ARE THE CLIENT'S HOLES.** `FrameXML.toc` lists 147 Lua entries;
140 extract. Two of the seven missing — `SharedXML\Logging.lua`, `Util\DevelopmentUtil.lua` —
are the two the client's own `FrameXML.log` reports as *"Error loading"*. The harness's reach
matches the client's, and that is evidence the read is faithful rather than partial.

**F3 · THE TEXT METRIC ANNOUNCED ITSELF IN BLIZZARD'S OWN CODE.** `PanelTemplates_TabResize`
does `textWidth = tabText:GetWidth()` (note: **not** `GetStringWidth`). Running the client's
real function made the hole name itself at a line number; a `TabResize` of ours would have
picked a width and hidden it. ★ **This is the argument for A10.1c's "load whole" over stubbing,
stated by the code rather than by us.** `F.TextMetric` is now a declared, pluggable guess —
which makes the A10.1c sweep one line: change it, re-run, and every rect that moved is
unverifiable.

## §355 · P2 — the lite build

**F4 · A10.1b'S WIDGET LIST IS TWELVE; `AceConfigDialog` CONSTRUCTS SEVENTEEN BY NAME**, and
the one that bit is **`Frame`** — its DEFAULT container (`AceConfigDialog-3.0.lua:1798`,
`f = gui:Create("Frame")`). Without it, `Dialog:Open` dies on `attempt to index local 'f'`.
★ Found by driving the real option table through the SHIPPED set rather than by reading a grep,
and every addition to the set is now justified by a **named failure** — so the set stays
minimal and each file can say why it is there. **A10.1b's list wants `Frame` added (13).**

**F5 · ★★ TABGROUP IS THE ONE FILE WHERE THE LITE BUILD STOPS BEING A MERGE AND BECOMES OURS.**
Both revisions' TabGroups fail here, **at opposite ends**:

    r960    calls the client's `PanelTemplates_TabResize` GLOBAL with the 3.3.5 argument
            order; this client's signature is modernised
            `(tab, padding, absoluteSize, maxWidth, absoluteTextSize)`, so r960's `width`
            lands in the slot read as `maxWidth`.
    r1403   vendors that function as a `local` - which looked like the field's own answer -
            but then wants retail-era tab FIELDS (`tab.HighlightTexture`, TabGroup.lua:288)
            that this client's `OptionsFrameTabButtonTemplate` does not provide.

★ **The client is modernised in its FUNCTIONS and not in its FRAMES**, and TabGroup sits exactly
on that seam. The fix is r960's widget with a `TabResize` written to **this** client's signature
— read from the archive, not guessed. ⚠ The r1403 swap was tried, refuted by measurement, and
**reverted rather than left half-done**: a file carrying "because it is newer" as its reason
would be carrying a reason we had already disproved.

**F6 · Where P2 stands.** The shipped set is **18 files, all r960** (5 core + 13 widgets +
licence), with a generated `MANIFEST.txt` recording every file's origin. Under it: core 5/5,
widgets 13/13, **`PerformLayout` RAN**, the Dungeon-Run option table **VALIDATES**. `Dialog:Open`
stops at F5's seam — the last thing between here and A10.1a's rendered frame.
