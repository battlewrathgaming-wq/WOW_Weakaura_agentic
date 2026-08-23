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
-- ⚠ NOT IN THE .toc YET. Nothing in the client consumes this until `task_sheet` lands; a file
-- loaded by the addon and read by nothing is a standing invitation to build on half a thing.
-- The repo tooling reads it from this path today.
--
-- ★ v1's text lists are TRANSCRIBED from `task_geom.lua`'s own FONTS / CALIBRATION / OURS,
-- deliberately and exactly - which is what makes the loop closeable against the seven geom
-- captures already on disk, with no client run. ⚠ That leaves TWO copies of the specimen list,
-- this one and task_geom's; the second is to be deleted when `task_geom` reads this file
-- instead. Noted rather than done: it changes a shipping capture task, and the proof does not
-- need it.

COA_UI_SHEET = {
    version = 2,

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
        templates = {
            "UIDropDownMenuTemplate", "UIPanelButtonTemplate", "InputBoxTemplate",
            "UICheckButtonTemplate", "UIPanelCloseButton", "OptionsBaseCheckButton",
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
}
