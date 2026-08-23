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
    version = 1,

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
}
