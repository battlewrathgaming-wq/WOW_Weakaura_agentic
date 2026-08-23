-- wrap_predict.lua - the OFFLINE wrapped-height model, callable from the reader.
--
-- ★★★ WHY IT IS A SCRIPT AND NOT A SECOND IMPLEMENTATION. `check_sheet.py` is Python and the
-- model lives in `frames.lua`; re-writing `WrapLines` in Python would be the second copy that can
-- disagree, and the whole sheet exists to stop exactly that. ⟶ So the reader WRITES a job here and
-- the model answers it. One source of truth, one subprocess, no port.
--
-- ⚠ THE CONTRACT IS DELIBERATELY DUMB - TSV in, TSV out, no JSON, no library:
--
--     stdin   uiScale                        (line 1)
--             size <TAB> width <TAB> text    (one per cell; text may contain spaces, never tabs)
--     stdout  lines <TAB> height             (one per cell, same order)
--
-- ★ It answers what `AceGUI Label` asks (`SetWidth` then `GetHeight`), through the same functions
-- the offline render uses - so a number here and a number in a rendered pane cannot drift apart.

package.path = (arg and arg[0] and arg[0]:gsub("[^/\\]+$", "") or "") .. "?.lua;" .. package.path
local F = require("frames")

local head = io.read("*l") or "1"
local scale, aspect = head:match("^([^	]*)	?(.*)$")
scale = tonumber(scale) or 1
aspect = tonumber(aspect)
F.SetUIScale(scale)
-- ★ The aspect decides the WIDTH quantum (q = 3*aspect/(10*uiScale)); absent it stays
-- nominal 16:9, which is right on a 16:9 screen and 0.0123% out elsewhere.
if aspect then F.SetAspect(aspect) end

local out = {}
for line in io.lines() do
    -- ⚠ Split on the FIRST TWO tabs only. A specimen string may legitimately contain
    -- anything else, and a greedy split would quietly truncate the sentence being measured.
    local font, width, text = line:match("^([^\t]*)\t([^\t]*)\t(.*)$")
    if font then
        local w = tonumber(width) or 0
        -- ★ The SIZE comes from the emitted table via the font OBJECT, not from the caller:
        -- one source for size, file and fitted constants, keyed by the name the client uses.
        local s = (F.FontSize and F.FontSize(font)) or 12
        local n = F.WrapLines(text, w, s, font)
        out[#out + 1] = string.format("%d\t%.9f", n, n * F.LineAdvance(s))
    else
        -- ⚠ NAMED, not skipped: a dropped row would silently shift every later row's
        -- pairing with its cell and the diff would be nonsense that looks like a finding.
        out[#out + 1] = "ERR\t0"
    end
end
io.write(table.concat(out, "\n"))
