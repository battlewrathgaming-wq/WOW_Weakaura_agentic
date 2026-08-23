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

local scale = tonumber(io.read("*l") or "1") or 1
F.SetUIScale(scale)

local out = {}
for line in io.lines() do
    -- ⚠ Split on the FIRST TWO tabs only. A specimen string may legitimately contain
    -- anything else, and a greedy split would quietly truncate the sentence being measured.
    local size, width, text = line:match("^([^\t]*)\t([^\t]*)\t(.*)$")
    if size then
        local s, w = tonumber(size) or 12, tonumber(width) or 0
        local n = F.WrapLines(text, w, s)
        out[#out + 1] = string.format("%d\t%.9f", n, n * F.LineAdvance(s))
    else
        -- ⚠ NAMED, not skipped: a dropped row would silently shift every later row's
        -- pairing with its cell and the diff would be nonsense that looks like a finding.
        out[#out + 1] = "ERR\t0"
    end
end
io.write(table.concat(out, "\n"))
