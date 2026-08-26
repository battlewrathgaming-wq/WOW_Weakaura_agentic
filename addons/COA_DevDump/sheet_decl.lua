-- sheet_decl.lua - THE UI TEST SHEET's declaration. One list of specimens, three readers.
--
-- ★★★ WHY IT IS DATA AND NOT CODE (Battlewrath, 2026-08-23): *"a test sheet for COA devdump.
-- Where we preload input types as one pane... swatch boards and placement checks so we have
-- basis for translating bench to in-game."* A pane we build, screenshot and eyeball is a
-- gallery. What makes this the translation layer is that the SAME declaration is rendered
-- twice - offline by `addons/tools/smoke/frames.lua`, in-client by COA_DevDump - and the two
-- results are diffed per cell. One declaration, two renderers, a machine-emitted divergence.
--
-- ★★ AND IT IS THE STANDARD, NOT A SAMPLE (his, same day): *"doing it against an active addon
-- only tells you about that addon rather than a broad insight."* ⟶ The rule that falls out,
-- and it is directional: **CALIBRATE on this sheet, CHECK our panes with the calibrated model,
-- never the reverse.** Tuning the offline model against the DungeonRun pane and then declaring
-- that pane correct because the model agrees is circular, and it would read as success.
--
-- ⚠⚠ APPEND-ONLY. A calibration standard whose specimens change is not a standard - every
-- prior run's numbers quietly stop being comparable and nothing would flag it. **Entries may
-- be APPENDED. An entry's meaning never changes in place, and nothing is reordered or removed.**
-- `check_sheet.py` prints a fingerprint of the expanded cell set on every run so any breach of
-- that is visible in the output and in the UI_LOG entry that cites it.
--
-- ★ IN THE .toc, and consumed. ⚠ THIS LINE READ *"NOT IN THE .toc YET"* UNTIL 2026-08-26 and
-- was stale - it is listed in `COA_DevDump.toc` between `range_walk.lua` and `task_sheet.lua`.
-- ⟶ The stale note was the standing reason the duplication below had not been repaid, which
-- is what a stale note costs: not a wrong fact on its own, but a decision left frozen behind it.
--
-- ★★★ AND `task_geom.lua` READS THIS FILE NOW (RI-81 item 3, 2026-08-26). Its own copies of
-- FONTS / CALIBRATION / OURS are DELETED; it takes `COA_UI_SHEET.text.fonts`,
-- `.calibration` and `.specimen` at RUN time and **refuses the run** if they are absent.
-- ⚠ A fallback copy would have been the second copy again wearing a safety net's clothes: a
-- run that quietly measured a different set would produce a standard that is not the standard,
-- and every offline reader would trust it.
--
-- ★ v1's text lists WERE transcribed from `task_geom.lua`, deliberately and exactly - which is
-- what made the loop closeable against the seven geom captures already on disk with no client
-- run, and what makes this repayment safe: the lists were identical, so captures before and
-- after remain comparable. That is the append-only rule doing its job.
--
-- ☆ It loads AFTER `task_geom.lua` in the .toc and that does not matter - the specimens are
-- read when the TASK RUNS, never at load. Left in .toc order rather than reordered: a load
-- order changed for a reason that does not exist is a change nobody can check.

COA_UI_SHEET = {
    version = 15,          -- v4: KIND `wrap` appended (sheet five, AL-45's offline half)
                          -- v5: wrap.fonts appended to sheet one's full eleven - two distinct
                          --     line advances is too thin a basis for a derived grid
                          -- v6: KIND `tab` appended (sheet six) - the text metric's CONSUMER
                          --     test: AceGUI sizes a tab from its text and WRAPS the strip
                          -- v7: KIND `collapse` appended (sheet seven) - what a section
                          --     weighs open, shut, and one-open
                          -- v8: KIND `range` appended (sheet eight) - the player from scratch
                          --     over a mock sample: playing and slicing, no display
                          -- v9: KIND `scroll` appended (sheet nine) - UL-16's third device
                          --     and the one that decides whether a height number is a
                          --     CONSTRAINT or a PREFERENCE
                          -- v10: KIND `pane` appended - THE SHEET'S OWN LAYOUT AS DATA, so
                          --     the machine can contradict it. Placed by hand until now.
                          -- v11: KIND `host` appended (sheet ten) - does an Ace container
                          --     POSITION a raw frame parented into it, or only widgets it
                          --     made itself? The question `DR_Pane_4`'s third state rests on.
                          -- v12: `host.arrangements` gains `seated` - the SAME question one
                          --     layer up, through AceConfigDialog's `dialogControl`, which
                          --     is the only route from an OPTION TABLE to a widget we wrote.
                          -- v13: `recycle` - DR_Pane_2 at the seat. A tab change is a
                          --     TEARDOWN, and AceGUI POOLS: does a re-acquired seat come
                          --     back carrying the last one's content, and its layout?
                          -- v14: `pane.arms` - what sits INSIDE a board, declared. Three
                          --     overflows in two hours lived in check_layout's own stated
                          --     blind spot; the arms were hand-placed in code, so there was
                          --     nothing for a machine to contradict.
                          -- v15: `widget` - WA's model. The composite IS a registered AceGUI
                          --     widget rather than a raw frame in a seat, so ReleaseChildren
                          --     reaches it. Measured AGAINST `recycle`, not instead of it.

    -- =================================================================
    -- KIND `text` - a font object x a string. The one number the offline
    -- rect model marks UNMEASURED (`F.Unmeasured()`), and so the first
    -- cell kind: text extent is text x font, and offline we have the font.
    --
    -- ★ The two string ROLES are the fit/hold-out split, not decoration.
    -- `calibration` strings are synthetic and yield a norm (ten Ms minus
    -- one M over nine is a per-glyph advance). `specimen` strings are real
    -- labels. Constants are fitted on the CALIBRATION strings alone and the
    -- error is reported on the SPECIMEN strings, which is the only honest
    -- measure of whether the sheet generalises - and generalising is the
    -- whole reason it exists rather than a run against a live pane.
    -- =================================================================
    text = {
        fonts = {
            "GameFontNormal", "GameFontNormalSmall", "GameFontNormalLarge",
            "GameFontHighlight", "GameFontHighlightSmall",
            "GameFontDisable", "GameFontDisableSmall", "GameFontRed",
            "ChatFontNormal", "ChatFontSmall", "NumberFontNormal",
        },

        -- ⚠ The empty string is deliberate and is a cell: a zero and a
        -- measurement that never happened look identical in a file, so the
        -- one width we KNOW must be zero is worth asserting. ⚠ `task_geom`
        -- stores it under the key "(empty)" - an adapter fact about the
        -- existing capture, carried in `check_sheet.py`, not a property of
        -- this standard.
        calibration = {
            "", "M", "MMMMMMMMMM", "i", "iiiiiiiiii", " ",
            "The quick brown fox jumps over the lazy dog",
        },

        specimen = {
            "identity", "detect", "action", "stage", "on-ramp", "children",
            "behaviour", "role", "shape", "reach", "target", "outcome",
            "move", "delete", "here", "pick", "ramp", "unseen",
            "right-click a beacon, a child or a note on the map",
        },
    },

    -- =================================================================
    -- KIND `control` (sheet two, 2026-08-23) - what an AceGUI widget BECOMES
    -- when asked for a width.
    --
    -- ★★★ SHEET TWO BUILDS ON SHEET ONE'S CAPABILITY, WHICH IS WHY IT IS SECOND
    -- (Battlewrath: *"A sheet at a time. Each building on the display capability of
    -- the next."*). AceGUI sizes a Button as `text:GetStringWidth() + 30` and a
    -- MultiLineEditBox's button as `label:GetStringWidth() + 24`; Flow wraps a row on
    -- content width. **String extent is the input to every one of those**, so the
    -- text sheet was not an arbitrary first - it is this sheet's prerequisite.
    --
    -- ★★ THE MIRROR IS WEAKAURAS, IN SUBSTANCE (his). `audit/ui_wa_grammar.md`
    -- establishes the editor's spatial vocabulary: WA authors AceConfig option tables
    -- and every width is a MULTIPLIER - `WeakAuras.normalWidth = 1.3` (`WeakAuras/
    -- Init.lua:7-9`), halfWidth 0.65, doubleWidth 2.6 - over AceConfigDialog's
    -- `width_multiplier = 170`.
    --
    -- ⚠⚠ AND OUR SHIPPED COPY CANNOT EXPRESS THAT VOCABULARY. `COA_DungeonRun/Libs/
    -- AceConfig-3.0/AceConfigDialog-3.0:1218-1225` is minor 49 and branches on the
    -- STRINGS "double" / "half" / "full" only; anything else - including a number -
    -- falls to the bare `width_multiplier`. So WA's 1.3 would silently render as 170,
    -- not 221. ★ The numeric rows below are declared ON PURPOSE so the capture
    -- DEMONSTRATES that in the client rather than leaving it a source reading.
    --
    -- ⚠⚠ WHICH COPY RUNS IS NOT OURS TO DECIDE. We ship AceGUI minor 33 and
    -- AceConfigDialog minor 49; LibStub keeps the HIGHEST minor loaded, and this
    -- client carries AceGUI up to 41 and AceConfigDialog up to 54 inside other
    -- addons. ⟶ `task_sheet` records the LIVE minors with every run. **A control
    -- measurement without them is not reproducible**, and that gate is the reason
    -- this kind could not simply be appended to sheet one.
    -- =================================================================
    control = {
        -- AceGUI widget type names. ⚠ Whatever LibStub hands us may not register all
        -- of them; a missing one is NAMED in the record, never counted as zero.
        widgets = {
            "Button", "CheckBox", "Dropdown", "EditBox", "Label", "Heading", "Slider",
        },

        -- Containers measured separately: they resolve `full` and give the inset every
        -- child's width is relative to.
        containers = { "SimpleGroup", "InlineGroup", "TabGroup" },

        -- The width vocabulary, both halves. `word` rows are what OUR AceConfigDialog
        -- actually branches on; `number` rows are WA's, expected to collapse to the
        -- default - and that expectation is the measurement, not an assumption.
        widths = {
            { how = "absent", value = nil,  why = "the widget's own natural size" },
            { how = "word",   value = "half",   why = "width_multiplier / 2" },
            { how = "word",   value = "normal", why = "not a branch - falls to width_multiplier" },
            { how = "word",   value = "double", why = "width_multiplier * 2" },
            { how = "word",   value = "full",   why = "fills the container" },
            { how = "number", value = 0.65, why = "WeakAuras.halfWidth" },
            { how = "number", value = 1.3,  why = "WeakAuras.normalWidth" },
            { how = "number", value = 2.6,  why = "WeakAuras.doubleWidth" },
        },

        -- The host width every `full` and every container inset resolves against.
        -- Fixed so a run at one resolution is comparable with a run at another.
        hostWidth = 400,

        -- ★ SOURCED, not chosen: `AceConfigDialog-3.0.lua:83` in the copy we ship.
        -- ⚠ WHAT THIS KIND MEASURES IS THE RECT, AND THE RECT IS NOT WHAT THE EYE SEES.
        -- See kind `art` below - that is the missing term, not a refinement of this one.
        -- ⚠ It is a LOCAL in that file and cannot be read at run time, so the task
        -- replicates AceConfigDialog's branch using this number and RECORDS it as a
        -- declared input. We are measuring what AceGUI DOES with a width, not what
        -- AceConfigDialog decides - and if a live copy ever used a different
        -- multiplier, this line is what a reader would compare against.
        widthMultiplier = 170,
    },

    -- =================================================================
    -- KIND `art` (sheet three, 2026-08-23) - how far the PICTURE runs past the RECT.
    --
    -- ★★★ THE RULE THIS EXISTS TO GENERALISE, already earned and already in code
    -- (`COA_DungeonRun/layout.lua:124-131`, §103 "the neighbour, not the edge"):
    --
    --     a rect check UNDER-REPORTS a dropdown BY DESIGN, and a pane can look wrong
    --     exactly where the arithmetic says it is fine
    --
    -- `UIDropDownMenuTemplate`'s three textures are 64 tall on a frame declared 32,
    -- anchored TOPLEFT at y = +17 - so the picture runs ~17 above the rect and ~15
    -- below. Sideways it is worse: `UIDropDownMenu_SetWidth(dd, w)` gives FIELD w,
    -- TEXT w-25 and ART w+50, and the arrow that reacts to a click lives out in that
    -- Right texture, entirely outside the frame you sized.
    --
    -- ⚠⚠ IT ALREADY COST A REAL BUG. The promoter asked for 200, read it as "200
    -- wide", and put a button at 208 - inside the 250 of art. The geometry run then
    -- measured the button as comfortably INSIDE its pane and the cause read as
    -- unknown, because every check we own compares rects. **It was the neighbour, not
    -- the edge.**
    --
    -- ★★ SO THIS KIND IS NOT A REFINEMENT OF `control`, IT IS THE MISSING TERM.
    -- `Layout.ART = { dropdown = { dw = 50, h = 64, dy = 17 } }` is one entry,
    -- hand-measured, for one template. This measures the same thing for every widget
    -- and container we use, per edge, from the client.
    -- =================================================================
    art = {
        -- Stock templates first: these are where the overhang is known to bite, and
        -- `task_geom` already measured their FRAME sizes - so art vs rect is directly
        -- comparable against a number we already hold.
        -- ⚠⚠ THE FRAME TYPE IS PART OF THE SPECIMEN, AND I LEFT IT OUT. v2 created every
        -- template as `CreateFrame("Frame", ...)`. `UIPanelButtonTemplate`,
        -- `UICheckButtonTemplate` and `UIPanelCloseButton` then drew NOTHING - in both the
        -- named and anonymous columns - because a Button's art lives in `<NormalTexture>` /
        -- `<PushedTexture>` / `<HighlightTexture>`, which are Button-specific elements a
        -- Frame does not have. ★ `InputBoxTemplate` rendered anyway and hid the bug: its
        -- textures are plain `<Layers>` regions, which a Frame DOES carry.
        --
        -- ★ SOURCED, never guessed - the XML element name is the type
        -- (`FrameXML/UIPanelTemplates.xml`, `SharedXML/UIDropDownMenu.xml`).
        -- ⚠ A v2 capture of those three measured a mis-built specimen. The cell SET did not
        -- change, so the fingerprint is unchanged and correctly so - what changed is the
        -- RECIPE. Records carry `declVersion`; anything below v3 is not comparable on
        -- those rows.
        templates = {
            { name = "UIDropDownMenuTemplate",  type = "Frame" },
            { name = "UIPanelButtonTemplate",   type = "Button" },
            { name = "InputBoxTemplate",        type = "EditBox" },
            { name = "UICheckButtonTemplate",   type = "CheckButton" },
            { name = "UIPanelCloseButton",      type = "Button" },
            { name = "OptionsBaseCheckButton",  type = "CheckButton" },
        },

        -- And the AceGUI widgets sheet two measured as rects, so the two kinds join
        -- on the same names.
        widgets = { "Button", "CheckBox", "Dropdown", "EditBox", "Label", "Heading", "Slider" },

        -- The size every subject is set to before its regions are read. Fixed so one
        -- run is comparable with another, and chosen to match sheet two's `normal`.
        probeWidth = 170,
        probeHeight = 32,

        -- ⚠ Only VISIBLE regions are unioned - a hidden texture draws nothing, so
        -- counting it would invent an overhang nobody can see. The skipped count is
        -- recorded rather than dropped, because "none were hidden" and "we did not
        -- look" are different facts.
        maxDepth = 4,
    },

    -- =================================================================
    -- KIND `behaviour` (sheet four, 2026-08-23) - does a widget actually OBEY the
    -- input-commit grammar?
    --
    -- ★★★ THE GRAMMAR IS ALREADY WRITTEN AND IT IS READ OFF ONE WIDGET'S SOURCE.
    -- `concepts/input-commit.md` states it - *OnTextChanged tells the USER,
    -- OnEnterPressed tells the RECORD* - with every line cited to
    -- `AceGUIWidget-EditBox.lua`. That is a claim about what the code says. This kind
    -- turns each line into a scripted experiment in the LIVE client and reports
    -- **claim vs observed vs agrees**, which is `/coadump r api`'s shape and is the
    -- house answer to "is this reasoned or measured".
    --
    -- ★★ THE RULING IT EXISTS TO PROVE (Battlewrath, 2026-08-23): *"I would avoid
    -- commit partial. Discard feels clunky. So stay pending."* A pending edit surviving
    -- focus loss is drivable - show the accept button, clear focus, read the button -
    -- so his ruling stops being a design intention and becomes a row that passes or
    -- fails on every run.
    --
    -- ⚠⚠ AND ONE HALF OF THE GRAMMAR CANNOT BE DRIVEN AT ALL. A real keystroke is the
    -- only source of `userInput = true`; `SetText` is always programmatic. So "type
    -- freely" is UNMEASURABLE from a script, and the record says so BY NAME rather
    -- than leaving a silent gap - the same discipline as `F.Unmeasured()`.
    -- ★ Every check also records HOW it was driven: `api` (a real client call) or
    -- `handler` (we invoked the registered script ourselves). A handler-driven result
    -- proves the handler, not the client's dispatch, and must not be read as more.
    -- =================================================================
    behaviour = {
        -- Widgets that take text. ⚠ Only these have a commit grammar; a Button or a
        -- Label has nothing to pend.
        subjects = { "EditBox" },

        -- The string written to drive a change. Must differ from the initial text or
        -- AceGUI's `value ~= lasttext` guard suppresses the event we came to see.
        probeText = "pending specimen",
    },

    -- =================================================================
    -- KIND `wrap` (sheet five, 2026-08-23) - a string's HEIGHT once it has a width.
    --
    -- ★★★ WHY IT EXISTS NOW: `ARCHITECT_LOG.md` AL-45 ruled YES to a cell kind whose
    -- height is MEASURED rather than looked up, and bounded it - *"offline, such a row
    -- is reported as UL-1 reports text: measured, quantised, MARKED; in-client the
    -- number is `GetStringHeight()` after `SetWidth()`."* ⟶ The offline half is this
    -- seat's, and it cannot be derived from UL-1's width finding: **a wrap point is a
    -- DECISION the client makes, not a number.** Width told us how far a string
    -- reaches; nothing told us where it breaks.
    --
    -- ★★ SO THIS KIND IS THE ONLY THING THAT CAN MAKE AN OFFLINE WRAPPED HEIGHT
    -- HONEST. Until it has run, an offline height is a guess wearing a number - which
    -- is exactly what `F.TextMetric`'s `0.55em` still is, and what UL-1 replaced for
    -- width. Calibrate here, then check panes with the calibrated model - never the
    -- reverse (the directional rule at the head of this file).
    --
    -- ⚠ THE MOTIVATING INSTANCE IS REAL AND IS IN THE SPECIMEN LIST. F·29 on
    -- Battlewrath's 2026-08-23 screenshot: the object pane's `completes when found`
    -- description wrapped to two lines inside a row sized for a checkbox, and drew
    -- through the `move` label on its left and under `Delete` on its right. The string
    -- below is that string. A standard whose specimens include the defect that created
    -- it can report whether the fix holds.
    --
    -- ⚠⚠ TWO NUMBERS PER CELL, AND WHAT `GetStringWidth` DOES AFTER `SetWidth` IS ONE
    -- OF THE THINGS BEING MEASURED. It may answer the unwrapped advance of the whole
    -- string or the widest laid-out line; ⚠ I do not know which on this fork and the
    -- record must not pretend to. Both numbers are stored per cell so the reader can
    -- say which it was - and a reader that saw only the height could not tell a
    -- two-line wrap from a font that is simply tall.
    -- =================================================================
    wrap = {
        -- ⚠ A SUBSET of the `text` kind's fonts, and deliberately: the join is on
        -- FONT NAME, so every font here already has its per-glyph advances measured by
        -- sheet one. Adding a font that sheet one does not carry would produce a height
        -- with no width model to predict it from.
        -- ⚠⚠ v5 APPENDED the remaining eight, and the reason is a measured weakness rather
        -- than completeness for its own sake. The first run derived a VERTICAL quantum
        -- `q_v` from these three fonts — and they collapse to TWO distinct line advances,
        -- because GameFontNormalSmall and GameFontHighlightSmall are the same file at the
        -- same size. **A grid derived from two values is a grid two values happen to lie
        -- on.** The other eight cost one run and turn two points into as many as the font
        -- set has distinct sizes.
        -- ★ They are exactly sheet one's list, so the join on font name still holds for
        -- every row.
        fonts = { "GameFontHighlightSmall", "GameFontNormal", "GameFontNormalSmall",
                  "GameFontNormalLarge", "GameFontHighlight",
                  "GameFontDisable", "GameFontDisableSmall", "GameFontRed",
                  "ChatFontNormal", "ChatFontSmall", "NumberFontNormal" },

        -- ★ The widths are the REAL content columns plus two forcing widths.
        --   600  wide enough that every string below is ONE line - which is how the
        --        single-line height is obtained, rather than assumed from the font size
        --   244  `interface/drive.md`'s content width
        --   204  `interface/object.md` and `map_controls.md`'s content width - the one
        --        F·29 happened in
        --   154  a dropdown's ASKED width (its art is +50; `concepts/art-and-rect.md`)
        --    96  narrow enough to break the short strings too
        --    60  the `edit` cell width the object pane uses for reach / ordinal / stage
        widths = { 600, 244, 204, 154, 96, 60 },

        -- Synthetic, so the wrap points are PREDICTABLE and a disagreement is about the
        -- client's rule rather than about our arithmetic on odd glyphs. ⚠ The repeated
        -- single word is the one case where any word-wrapping implementation must agree
        -- with any other; if the offline model misses THIS, it is not a tuning problem.
        calibration = {
            "word word word word word word word word word word word word",
            "M M M M M M M M M M M M M M M M M M M M",
            "iiiiiiiiii iiiiiiiiii iiiiiiiiii iiiiiiiiii",
            "supercalifragilisticexpialidocious",   -- ⚠ ONE token longer than 60px:
                                                    -- what the client does with a word
                                                    -- that cannot fit is a RULE we do
                                                    -- not know and must not invent
        },

        -- Real strings off the panes. The first is F·29 itself.
        specimen = {
            "completes when found - but not before he reaches",
            "Cooldown Numbers might be added by WoW. You can configure these in the game settings.",
            "satisfying this promotes the index to 4",
            "0 beacons - 0 personal notes here",
            "select a point on the map",
            "pick a run above",
        },

        -- (see `probeMethods` below)
        -- ⚠⚠ NAMED, NOT CALLED BLIND. `SetWordWrap` and `GetNumLines` are later-client
        -- API and this is 3.3.5; `SetNonSpaceWrap` is expected but expectation is not
        -- evidence on this fork. The task RECORDS which of these the FontString
        -- actually has and calls none it does not - the same discipline as
        -- `CombatLogGetCurrentEventInfo` being furniture here.
        probeMethods = { "SetNonSpaceWrap", "SetWordWrap", "GetNumLines", "GetStringHeight" },
    },

    -- =================================================================
    -- KIND `tab` (sheet six, 2026-08-24) - do tabs WORK, and can we predict them before
    -- we build the pane?
    --
    -- ★★★ HIS COMMISSION: *"I think next is our sheet. Prove we can make tabs that work.
    -- And then tabs and sub-tabs. (One to move the page. One to move sub-page content.)"*
    --
    -- ★★ AND "WORK" IS NOT "RENDER". A strip that renders and then silently wraps to two
    -- rows has moved every control below it by a row's height, on a pane that is 240 wide
    -- and has no room to spare. ⟶ The thing worth proving is that the OFFLINE model gets
    -- the same answer as the client - which is the sheet's whole shape, applied to the one
    -- widget the surface structure now depends on.
    --
    -- ★★★ AND IT IS THE HARDEST TEST THE TEXT METRIC HAS. `AceGUIContainer-TabGroup.lua`
    -- does not lay tabs out from a number we choose:
    --     :42   PanelTemplates_TabResize(frame, 0, nil, width)   -- sizes the tab to its TEXT
    --     :193  widths[i] = tab:GetWidth() - 6
    --     :207  if usedwidth ~= 0 and (width - usedwidth - widths[i]) < 0 then  -- WRAP
    -- ⟶ every tab's width comes from `tabText:GetWidth()`, so the ROW COUNT is a function of
    -- the font metric. A model that is 5% out on a string can be a whole row out on a strip.
    -- **This kind is the text metric's consumer test, not a second measurement of it.**
    --
    -- ⚠ NOT A DECISION ABOUT THE PRODUCT. `AI-24` records his structure - three tabs on the
    -- unified pane, two on the remote - and the sets below MEASURE those rather than propose
    -- anything. If `Curation · Promotion · Object` needs two rows at 240, that is a fact the
    -- Addon creator needs before building, not an argument from this seat.
    -- =================================================================
    tab = {
        -- ⚠ The REAL widths, so the answer is about our panes and not about a demo.
        --   240  the unified bolt-on and the remote (`interface/remote.md`, `object.md`)
        --   280  `drive.md`
        --   200  narrower than anything we ship - the forcing case
        --   400 / 600  wide enough that nothing should wrap, which is the control
        widths = { 200, 240, 280, 400, 600 },

        -- ★ Each set is a strip we actually intend to draw, plus two synthetic ones.
        -- `calibration` sets have predictable text so a disagreement is about the WRAP RULE;
        -- `specimen` sets are the product's own, where a disagreement is about the METRIC.
        calibration = {
            { name = "three-M",   tabs = { "M", "M", "M" } },
            { name = "three-wide", tabs = { "MMMMMMMMMM", "MMMMMMMMMM", "MMMMMMMMMM" } },
            -- ⚠ Eight tabs guarantees wrapping at every width above. Without a set that is
            -- CERTAIN to wrap, a run where nothing wrapped would prove nothing about the
            -- row rule and would read as success.
            { name = "eight",     tabs = { "one", "two", "three", "four",
                                           "five", "six", "seven", "eight" } },
        },

        specimen = {
            -- AI-24, his structure
            { name = "unified",   tabs = { "Curation", "Promotion", "Object" } },
            { name = "remote",    tabs = { "Run", "Test drive" } },
            -- `ui_overhaul_scope.md` THE FOUR TAB STRIPS, derived from what a node IS
            { name = "beacon",    tabs = { "Face", "Stage 1", "Stage 2" } },
            { name = "beacon-kids", tabs = { "Face", "Children", "What they are doing" } },
            { name = "child-first", tabs = { "Face", "Stage 1", "Action (N)" } },
            { name = "child",     tabs = { "Face", "Action (N)" } },
        },

        -- ★★ SUB-TABS - his second half, *"one to move the page, one to move sub-page
        -- content"*. A TabGroup placed INSIDE a TabGroup's content: measured for whether it
        -- renders at all, how many rows IT takes, and what vertical room is left underneath.
        -- ⚠ The inner set is deliberately the node's own strip, because that is the actual
        -- nesting the design asks for: Object (outer) -> Face/Stage 1/Stage 2 (inner).
        nest = { outer = "unified", innerAt = 3, inner = { "Face", "Stage 1", "Stage 2" } },

        -- The height a container is given before its strip is built. Fixed so one run is
        -- comparable with another.
        probeHeight = 220,
    },

    -- =================================================================
    -- KIND `collapse` (sheet seven, 2026-08-24) - what a section WEIGHS open and shut.
    --
    -- ★★★ HIS COMMISSION: *"Last proof for the sheet, in the same WA type. Is a collapsing
    -- draw of data / fields."*
    --
    -- ★★ WA'S MECHANISM, READ BEFORE BUILDING (`WeakAurasOptions/CommonOptions.lua`):
    --     :306  addCollapsibleHeader(result, optionGroup, options, groupBase, isGroupTab)
    --     :139  the header is `type = "execute"` - A BUTTON, not a widget with children
    --     :113  IsCollapsed("collapse", "region", key, defaultCollapsed)   -- a STORED FLAG
    --     :121  SetCollapsed(..., not isCollapsed)
    --     :293  every member of the section gets  resultOption.hidden = collapsedFunc
    --     :285  ...or a WRAPPER: collapsed OR the option's own hidden
    -- ⟶ Nothing hides children. The OPTION TABLE declares them hidden and the dialog
    -- re-feeds. ★ And :285-291 is the subtle half: collapse COMPOSES with an existing
    -- `hidden` rather than replacing it - which is exactly what our `rowHidden` static
    -- subject set would have to do.
    --
    -- ⚠⚠ AND WE CANNOT COPY IT, WHICH IS SAID HERE RATHER THAN DISCOVERED LATER. WA drives
    -- AceConfigDialog from an option table; `panespec.lua` is zones→rows→cells with
    -- `rowHidden` as a STATIC subject set, kept static because it is offline-checkable
    -- (`ui_overhaul_scope.md`). So this kind measures the ACEGUI form - a Button header and
    -- children added or removed - and records WA's option-table form as the cited original.
    -- **The shape is borrowed; the mechanism is not the same and the record says so.**
    --
    -- ★★★ AND IT IS THE PANE'S OWN QUESTION. `F·30` measured the object pane ~730 tall with
    -- content ending ~570; `UL-13` measured two tab strips at 94 of 220. Both are "what does
    -- the furniture cost". Collapse is the only lever left that does not remove a control,
    -- and the number that decides it is **what a shut section weighs**.
    -- =================================================================
    collapse = {
        widths = { 240, 280 },

        -- ⚠ The SECTIONS ARE THE OBJECT PANE'S OWN ZONES (`interface/object.md`), with the
        -- real control counts. A synthetic section would measure the widget set; these
        -- measure the pane we intend to build.
        -- `summary` is what the SHUT header says - WA's `1. Desaturate: OFF` idiom, where a
        -- collapsed row still carries its state. A header that only says its name turns
        -- collapse into hiding.
        sections = {
            { name = "identity",  summary = "Identity — beacon 3",      fields = 8 },
            { name = "detects",   summary = "Detects — reach 8 yd",     fields = 8 },
            { name = "does",      summary = "Does — advance stage",     fields = 3 },
            { name = "stage",     summary = "Stage — 3, free",          fields = 3 },
            { name = "note",      summary = "Note — 1 line",            fields = 2 },
        },

        -- The widget every field is drawn as. ⚠ ONE kind, deliberately: this sheet asks what
        -- a SECTION weighs, and mixing widget heights would fold sheet two's question into
        -- sheet seven's answer.
        fieldWidget = "EditBox",

        -- ★ Measured in three states, because the middle one is the design:
        --     open       every section expanded
        --     shut       every section collapsed to its header
        --     one-open   the first open, the rest shut - what a person actually sees
        states = { "open", "shut", "one-open" },
    },

    -- =================================================================
    -- KIND `range` (sheet eight, 2026-08-24) - the player, from scratch, over a MOCK
    -- sample. No map, no nodes drawn: just PLAYING and SLICING.
    --
    -- ★★★ HIS COMMISSION: *"Do you want to build a demo for the test sheet from scratch.
    -- With a mock sample for it to walk? (No display, just the function of the player -
    -- playing and slicing)"*
    --
    -- ★★ AND THE MOCK SAMPLE IS WHAT MAKES IT A STANDARD. `ui_custom_controls_inventory.md`
    -- said the range could not be a sheet kind because *"one instance is a specimen, not a
    -- standard"* - there is exactly one range control and it is welded to a loaded run. A
    -- SYNTHETIC timeline removes both: the same events every run, and no run needed.
    --
    -- ★★★ AND IT SPLITS CLEANLY IN TWO, which is why it is worth building:
    --     THE WALK      pure arithmetic - which events fall in a slice. NO widgets at all,
    --                   so the OFFLINE model runs the identical walk and is diffed against
    --                   the client. A function, proven like a function.
    --     THE TARGETS   geometry - where the four grab areas ARE. Needs the client.
    -- ⟶ The half carrying the design's risk - does slicing do what we think - is the half
    -- that needs no client at all.
    --
    -- ⚠ THE THREE QUANTITIES ARE SEPARATE HERE BY CONSTRUCTION, and that is the point.
    -- `map.lua:670` fuses breadth and position in `Map.Window(pos, width)`; this demo keeps
    -- envelope · breadth · position as three, because his arrangement (one bar, handles
    -- above and below, the slice body draggable) cannot be built any other way.
    -- =================================================================
    range = {
        -- ★ THE MOCK SAMPLE. Irregular on purpose: evenly spaced events would make every
        -- slice hold the same count and hide an off-by-one at a boundary.
        -- ⚠ Two events at the SAME second (22, and again 48) and two at the exact ends
        -- (0 and 120) - the boundary cases a real run produces and a tidy sample would not.
        sample = {
            0, 3, 7, 8, 15, 22, 22, 29, 34, 41,
            48, 48, 55, 61, 62, 63, 70, 78, 85, 91,
            97, 104, 112, 120,
        },
        span = 120,          -- the run's full duration, the conversion basis

        -- ★★ THE WALK - a fixed script, so offline and client must produce the SAME
        -- selection at every step or one of them is wrong.
        -- ⚠ `skip` carries no size: the step is DERIVED (breadth / 10), which is
        -- `map.lua:665`'s rule - *ten presses always crosses whatever you framed*.
        walk = {
            { "envelope", 0, 120 },
            { "breadth", 20 },
            { "at", 0 },
            { "skip", 1 },
            { "skip", 1 },
            { "skip", 1 },
            { "wider" },
            { "skip", 1 },
            { "narrower" },
            { "at", 60 },
            { "envelope", 40, 80 },   -- ★ shrink the envelope UNDER the slice
            { "skip", 1 },            -- and step at the clamped edge
            { "at", 120 },            -- ★ a position outside the envelope
            { "wider" }, { "wider" }, { "wider" },   -- ★ wider than the envelope allows
        },

        -- The pane widths the control is built inside.
        widths = { 204, 244 },

        -- ⚠ The grab targets his arrangement creates. The check that matters is that NO TWO
        -- OVERLAP - the whole reason for putting handles on both sides of one bar rather
        -- than stacking them in Z.
        targets = { "envLo", "envHi", "sliceLo", "sliceHi", "sliceBody" },
    },

    -- =================================================================
    -- KIND `scroll` (sheet nine, 2026-08-24) - the last of the three display
    -- devices `UL-16` named, and the one it called the hole that "most changes
    -- a height budget".
    --
    -- ★★★ WHAT THIS SHEET IS FOR, and it is NOT "does a ScrollFrame work".
    -- `UL-16`: *"Until `ScrollFrame` exists, every statement about what fits
    -- describes a pane that cannot scroll."* ⟶ The question is what scroll does
    -- to the height numbers we ALREADY HOLD. Once a pane scrolls, a height stops
    -- answering *does this fit* and starts answering *how far do you travel*.
    --
    -- ★★ SO THE CONTENT HEIGHTS ARE NOT INVENTED - they are `UL-14`'s three
    -- measured collapse states (744 open · 328 one-open · 120 shut). Sheet nine
    -- answers sheet seven's numbers rather than measuring in the abstract.
    --
    -- ⚠⚠ FIRST DRAFT CORRECTED BEFORE IT EVER RAN. It declared three `probes`
    -- - barWidth · wheelStep · clips - as facts a client run would discover.
    -- One targeted read of the upstream container (`AI_VoiceOver/Libs/AceGUI-3.0/
    -- widgets/AceGUIContainer-ScrollFrame.lua`, the same file `audit/
    -- ace3_gap_2026-08-24.md:210` names) answered all three from SOURCE, and
    -- showed one of them was not a client fact at all: the wheel is the ADDON's
    -- (`:173-174` EnableMouseWheel + OnMouseWheel -> MoveScroll), so a wheel step
    -- is a design value we settle, never a constant we measure.
    -- ★ Amended in place and said out loud because this kind has never been run:
    -- no prior numbers depend on it, so nothing silently stops being comparable.
    -- Amending it after a run would be the breach the file's header forbids.
    -- =================================================================
    scroll = {
        -- The pane widths the viewport is built inside - the same two `range` and
        -- `collapse` use, so the numbers JOIN rather than sit beside.
        widths = { 204, 244 },

        -- ★ `UL-14`'s measured collapse states, transcribed.
        --   744 = every section open · 328 = one open · 120 = all shut
        contents = { 120, 328, 744 },

        -- 200 makes even the SHUT state overflow; 400 leaves 120 and 328 fitting
        -- and only 744 over. ⚠ Both matter: a viewport TALLER than its content must
        -- report a range of ZERO, and a correct zero is indistinguishable from a
        -- failed one unless the sheet asserts both.
        viewports = { 200, 400 },

        -- =============================================================
        -- ★★★ WHAT UPSTREAM DECLARES - CITED, to be CHECKED in-client, never
        -- rediscovered. Every line is `AceGUIContainer-ScrollFrame.lua`.
        -- ⚠ Checked and not assumed because this fork customises at the CALLER
        -- layer, so an upstream constant is a claim about upstream, not about here.
        -- =============================================================
        upstream = {
            barWidth  = 16,    -- :183  scrollbar:SetWidth(16)
            widthCost = 20,    -- :114  scrollframe:SetPoint("BOTTOMRIGHT", -20, 0)
                               -- :117  content.width = original_width - 20
            margin    = 2,     -- :102  `if viewheight < height + 2 then` - hide the bar.
                               --       Deliberate, with its own comment: "No-one is going
                               --       to miss 2 pixels at the bottom of the frame".
            scaleMax  = 1000,  -- :120  the bar's value space is 0..1000, NOT pixels.
                               --       ⚠ A scroll POSITION and a scroll PIXEL are
                               --       different units and the widget mixes both.
        },

        -- =============================================================
        -- ★★★ THE CLIFF - and this is sheet nine's actual finding, not the demo.
        --
        -- The scrollbar appears iff  content >= viewport + 2  (:102), and its
        -- appearance costs **20 of WIDTH** (:114, :117). ⟶ So the width available
        -- to content is not a property of the pane. It is a property of the pane
        -- AND its current content height, and it changes by 20 at a threshold.
        --
        -- ⚠⚠ WHICH IS A FEEDBACK LOOP, and it is why this is worth a sheet:
        -- content one pixel over the line gains a bar, LOSES 20px of width, and
        -- narrower content WRAPS TALLER - pushing it further over, never back.
        -- ★ 20 of 204 is ~10%, and sheet five measured wrap over 660 cells at
        -- exactly these widths. So sheet nine joins sheet five to sheet seven:
        -- does the width a bar takes change the LINE COUNT, and therefore the
        -- height, of content that was already only just too tall?
        --
        -- These probes straddle the +2 margin on both sides at both viewports.
        -- ⚠ The pairs at -1/+1 and -3/+3 are the assertion: the ONLY difference
        -- between them is which side of a documented threshold they fall.
        -- =============================================================
        cliff = { -3, -1, 0, 1, 2, 3, 5 },   -- offsets applied to each viewport height

        -- ★★ THE WALK - a fixed script; offline and client must agree at every
        -- step or one of them is wrong. Steps are in the widget's OWN 0..1000
        -- space, not pixels, because that is the unit the bar actually carries.
        -- ⚠ The two CLAMP steps are the point, not the travel: past the end must
        -- move nothing. A pane that scrolls past its content looks broken and
        -- reports nothing.
        walk = {
            { "top" },
            { "step", -100 },
            { "step", -100 },
            { "step", -100 },
            { "step",  100 },
            { "bottom" },
            { "step", -100 },   -- ★ CLAMP at the bottom
            { "top" },
            { "step",  100 },   -- ★ CLAMP at the top
        },
    },

    -- =================================================================
    -- KIND `pane` (2026-08-25) - ★★★ THE SHEET'S OWN LAYOUT, AS DATA.
    --
    -- His ask: *"Do we need a resolver that can argue a fixed pane size and then placement
    -- within?"* ⟶ The answer was NO to both halves and YES to a third thing:
    --   placement WITHIN a board   AceGUI publishes it (Flow/List/Fill/Table) - a COAT
    --   ARGUING a pane size        `UL-16` already ruled against it: a measurement is of
    --                              TODAY and never a constraint on the design. A machine
    --                              that PICKS a size promotes a fits-today number into a rule.
    --   CHECKING a declared size   ⟵ this. And `frames.lua` has published `F.Overlaps`,
    --                              `F.Outside`, `F.Containment` and `F.OverlapsTree` the
    --                              whole time, with NOTHING calling any of them.
    --
    -- ⚠⚠ AND THE FIRST RUN OF THE CHECKER FOUND A REAL OVERLAP IN §645's PAGE 2 -
    -- `rangeBoard` (x 0..530) crossing `collapseBoard` (x 442..682) by 88 x 96. Shipped,
    -- on screen, and invisible to five hand placements across three turns.
    -- ★ Declared here AS IT WAS FIRST, so the tool's first output was a finding and not a
    -- clean bill - `wrong isn't failure, emit don't interpret`.
    --
    -- ★★ IT MUST BE READ, NOT MIRRORED. `buildSheet` consumes this table; it does not keep
    -- its own copy of the numbers. A declaration the builder ignores is the second copy that
    -- drifts, which is the fault the `tools` skill's own page is written about.
    --
    -- ⚠ Y IS NEGATIVE-DOWN, as `SetPoint` takes it. The checker converts once, at the edge.
    -- =================================================================
    -- =================================================================
    -- KIND `host` (sheet ten, 2026-08-26) - THE THIRD STATE, measured.
    --
    -- ★★★ HIS QUESTION, and it is the one the whole thing turns on: *"Does ace still
    -- handle the position on the hosted frame, or do we hand place that range?"*
    --
    -- ⚠⚠ AND IT CANNOT BE ANSWERED FROM OUR OWN CODE, which is where the bench tried
    -- first and was corrected. `options.lua`'s `SeatMap` looks like the precedent and is
    -- not: `mapSeat:SetLayout(nil)` turns Ace's layout OFF, and the function has NO CALLER
    -- in the addon - only two in a smoke. An existence check dressed as evidence.
    -- ⟶ So it is measured HERE, in the client, which is what the sheet is for.
    --
    -- ★★ THREE STATES, and only the middle one is undetermined:
    --     ace       AceConfig forms it            run · rename · comment · the filters
    --     hosted    a raw composite in a seat     the playback bar, its handles, steppers
    --     frame     earns a window of its own     the map canvas (`DR_Pane_4`'s exception)
    --
    -- ⚠ `hosted` is the state with a working instance already - `task_sheet`'s own range
    -- board is a raw frame with textures - but it sits on a RAW page, so nothing about Ace
    -- was ever exercised. What is unknown is whether a LIVE layout will place it.
    --
    -- ★ THE SECOND MEASURE IS THE ONE THAT BITES. Even if Ace never positions the child,
    -- the container's HEIGHT still has to account for it - or a pane sizes itself as though
    -- the control is not there, which is `DR_Pane_8`'s reserved space with the sign flipped.
    -- =================================================================
    host = {
        -- The seat sizes, matching `scroll` and `range` so the numbers JOIN rather than
        -- sit beside. A hosted composite has to fit the same columns.
        widths = { 204, 244 },

        -- The raw child's size. ⚠ DELIBERATELY NOT the seat's: a child that happens to fit
        -- exactly cannot show whether the container sized it or left it alone.
        child = { w = 120, h = 40 },

        -- ★★ THE ARRANGEMENTS, and the pair is the point. `direct` is what a builder would
        -- try first; `wrapped` is the fallback if it fails, and if BOTH fail then a hosted
        -- composite must carry its own placement and `panes_decl` has to say so.
        arrangements = {
            -- Parent the raw frame straight into the container's `.content`.
            "direct",
            -- Give it an AceGUI SimpleGroup of its own via `AddChild`, then parent into
            -- THAT widget's content - the child is a widget Ace made, holding a frame.
            "wrapped",
            -- ★★★ SEATED (v12) - the same question ONE LAYER UP, and the layer that
            -- matters: the unified pane is an OPTION TABLE, and an option table cannot
            -- `AddChild` anything. `AceConfigDialog-3.0.lua:1119` reads
            -- `v.dialogControl or v.control` and calls `gui:Create(controlType)`, so a
            -- REGISTERED widget type is the only route from a table to a widget we wrote.
            -- ⚠ `smoke_dungeonrunoptions` proves the Dialog BUILDS one, offline. What a
            -- smoke cannot say is what that widget is GIVEN when a real Dialog lays out a
            -- real table - its position, and whether the height it reports is the height
            -- reserved. Those are client facts and belong here.
            "seated",
            -- ★★★ RECYCLE (v13) - `DR_Pane_2` where it actually bites. His ask,
            -- 2026-08-26: *"I ask for the tear down and reconstruction. On tab change, a
            -- whole new set of controls is needed."*
            --
            -- ⚠⚠ ACEGUI POOLS BY TYPE (`AceGUI-3.0.lua:124-156`), and two things follow
            -- that a reader would not expect:
            --   · `AceGUI:Release` calls `ReleaseChildren`, which releases child WIDGETS.
            --     A raw FRAME is not a widget child, so it cannot be seen and rides into
            --     the pool still parented to the seat.
            --   · `AceGUI:Create` sets the layout to "List" AFTER `OnAcquire` (:193-194),
            --     so a `SetLayout(nil)` written in the CONSTRUCTOR is overwritten on every
            --     acquisition - it holds for the first instance and no other.
            -- ⟶ Both are SOURCE READS. This arm measures them, because a read is not a
            -- measurement and this bench has been corrected on that twice in one day.
            "recycle",
            -- ★★★ WIDGET (v15) - WEAKAURAS' MODEL, and it is prior art rather than a design.
            -- His steer, 2026-08-26: *"Review how WA handles it's templates. As they
            -- disappear once a aura is loaded. And they use ace."*
            --
            -- ★★ WA TEARS ITS WHOLE TEMPLATE VIEW DOWN IN ONE LINE
            -- (`WeakAurasTemplates/TriggerTemplates.lua:1651`):
            --     newViewScroll:ReleaseChildren()
            -- ⟶ Which works because EVERY CHILD IS AN ACEGUI WIDGET. The raw frames are not
            -- gone - they live INSIDE each widget's constructor
            -- (`AceGUIWidget-WeakAurasIconButton.lua:64-95`: CreateFrame, textures, scripts,
            -- then `AceGUI:RegisterAsWidget`), and each widget implements `OnAcquire` and
            -- `OnRelease`. Thirty-one of them ship in `WeakAurasOptions/AceGUI-Widgets`.
            --
            -- ⚠ SO EVERY FAULT `recycle` MEASURED - hidden on release, unparented,
            -- unanchored, stale content surviving `ReleaseChildren` - comes from keeping the
            -- composite OUTSIDE the abstraction. This arm keeps it inside and asks whether
            -- the same release/re-acquire comes back CLEAN.
            -- ★ `recycle` STAYS. The comparison is the finding, not the replacement.
            "widget",
        },

        -- ★ WHAT EACH ARRANGEMENT MUST REPORT. Recorded as a list so a capture that
        -- answers three of four is visibly incomplete rather than quietly short.
        reports = {
            "movedX", "movedY",     -- did DoLayout change the child's position at all
            "childW", "childH",     -- and did it SIZE it - a layout that resizes is worse
                                    -- than one that ignores, for a composite with a scale
            "contentH",             -- the container's own height AFTER the layout
            "seesChild",            -- did that height account for the child at all
        },

        -- ⚠ THE CONTROL CASE. A real AceGUI widget in the same container, same layout, so
        -- *"Ace positioned nothing"* and *"the layout never ran"* cannot be confused - the
        -- fault this bench has met as a stubbed harness passing for the wrong reason.
        control = "Label",

        -- ★ THE SEAT'S REGISTERED TYPE NAME, for the `seated` arm. Declared rather than
        -- typed in the builder so the sheet and any consumer name the same widget.
        -- ⚠ NAMING IT IS THE UI SEAT'S (UI-4): the bench calls it a *seat* in prose, and
        -- `type-or-feature.md` decides whether it is a TYPE at all. This is a test name and
        -- carries no claim about the registry's.
        seatType = "COASheetSeat",

        -- ⚠ `dialogControl` IS READ ON THESE THREE ONLY (`:1119` · `:1175` · `:1194`), not
        -- on every option type. A hosted control declares one of them and overrides the
        -- widget - which is the documented AceConfig custom-control path, not a trick.
        seatOn = { "input", "select", "multiselect" },
    },

    pane = {
        sheet  = { w = 1010, h = 612 },
        title  = { x = 18,  y = -18 },
        strip  = { x = 470, y = -16, w = 120, h = 22, gap = 124, n = 3 },
        page   = { x = 18,  y = -70, w = 974, h = 524 },

        -- Each board is placed INSIDE its page's box, so the page is the containment box
        -- and a board that leaves it is an overhang rather than a mystery.
        boards = {
            { page = 1, name = "host",          x = 0,   y = 0,    w = 420, h = 270 },
            { page = 1, name = "board",         x = 442, y = 0,    w = 530, h = 520 },
            { page = 2, name = "tabBoard",      x = 0,   y = 0,    w = 420, h = 324 },
            -- ⚠ FIXED 2026-08-25 from `check_layout`'s first clean run: rangeBoard was 530
            -- wide and crossed collapseBoard by 88 x 96. Narrowed to 420 (matching tabBoard
            -- above it, which is also why the column now reads as a column) and the other two
            -- shifted left. ★ The machine named the pair and the overlap in both axes; five
            -- hand placements had not.
            { page = 2, name = "collapseBoard", x = 436, y = 0,    w = 240, h = 520 },
            { page = 2, name = "rangeBoard",    x = 0,   y = -348, w = 420, h = 96  },
            { page = 2, name = "scrollBoard",   x = 692, y = 0,    w = 240, h = 240 },
            -- ★ Under `scrollBoard`, in the column both already use. Placed as a
            -- DECLARATION and contradicted by `check_layout` before anything was built.

            { page = 3, name = "protoBoard",    x = 0,   y = 0,    w = 960, h = 168 },
            -- ⚠⚠ MOVED FROM PAGE 2 AT v13. Four arms never fitted under `scrollBoard`: the
            -- SEATED arm alone put 374 of content (a holder at -258 reporting 116) into a
            -- board of 264, and TWO captures did not show it. ★ `check_layout` states its
            -- own blind spot - it checks boards against each other and their page, and has
            -- no view INSIDE a board - and this is that gap one size up.
            -- ⟶ Page 3 is *"prototypes"*, which is what a hosted-composite seat is, and
            -- `protoBoard` uses 168 of 524 so the room is real rather than squeezed.
            -- ⚠⚠ 620 WIDE FOR TWO COLUMNS (v13, after the screenshot). Four arms stacked
            -- need ~420 of height and the page allows 332 below `protoBoard` - so they sit
            -- two and two. ★ Page 3 is 974 across and `protoBoard` ends at y -168, so the
            -- width was always there; the first cut took 300 because the arms were a column.
            { page = 3, name = "hostBoard",     x = 0,   y = -192, w = 620, h = 330 },
        },

        -- =============================================================
        -- ★★★ THE ARMS - what sits INSIDE a board (v14, 2026-08-26).
        --
        -- ⚠⚠ WHY THIS EXISTS, and it is three faults in two hours rather than a tidy-up:
        --   1. the seated arm overflowed a 264 board - found by arithmetic, after landing
        --   2. `hostBoard` was DECLARED AND NEVER BUILT, so two captures drew on UIParent -
        --      found by Battlewrath's eye: *"last time they was just on the UI"*
        --   3. the arms overflowed again after the board moved to page 3 - found by READING
        --      THE SCREENSHOT, at his prompt
        --
        -- ★ AND `check_layout` WAS NEVER AT FAULT. It states its limit: *"it checks boards
        -- against each other and against their page; it has no view of a FontString wider
        -- than the board it sits in."* Three misses in one blind spot is the blind spot
        -- behaving exactly as documented.
        --
        -- ⟶ THE ROOT CAUSE WAS THAT THE ARMS WERE HAND-PLACED IN CODE. The board was
        -- declared and the offsets were typed, so there was nothing for a machine to
        -- contradict - the same shape `panes_decl` removed one layer up, still live here.
        --
        -- ⚠ `board` is the containment box, exactly as `page` is for a board. Coordinates
        -- are RELATIVE to their board's top-left, negative-down, as SetPoint takes them.
        arms = {
            { board = "hostBoard", name = "direct",  x = 0,   y = -18,  w = 204, h = 110 },
            { board = "hostBoard", name = "wrapped", x = 0,   y = -138, w = 204, h = 110 },
            -- ⚠ THE SEATED ARM IS DECLARED AT ITS MEASURED HEIGHT, not its asked-for one.
            -- The holder is created 96 tall and the Dialog GROWS it to 116 (capture
            -- 20260826_212033_227). Declaring 96 would be declaring a number the client
            -- overrules, and the overflow it caused is the reason this block exists.
            { board = "hostBoard", name = "seated",  x = 320, y = -18,  w = 204, h = 116 },
            { board = "hostBoard", name = "recycle", x = 320, y = -160, w = 204, h = 60  },
            -- ★ Column one, under `wrapped`. Same size as `recycle` so the two read as a
            -- PAIR - they ask one question of two models.
            { board = "hostBoard", name = "widget",  x = 0,   y = -258, w = 204, h = 60  },
        },
    },
}
