-- The SHIPPED lite Ace3, loaded in the .toc's own order. One copy, two callers.
--
-- ★★ IT LOADS THE REAL LIBRARY. Nothing here models Ace; it IS Ace, running under lua51
-- against `frames.lua`. A smoke that asserts an AceGUI widget's state is only worth
-- anything on this footing.
--
-- ⚠ WHY THIS FILE EXISTS. `smoke_dungeonrunoptions.lua` carried this block inline, and
-- when the remote folded onto AceGUI a second smoke needed the identical block. A second
-- copy is a fork waiting to happen: the widget list is read from DISK, so the two copies
-- would agree today and diverge the first time a widget file is added and only one of
-- them is looked at. `machines-do-the-mechanical-work` - defined I/O, build once.
--
-- ⚠ `probe_ace.lua` DELIBERATELY DOES NOT USE THIS. Its job is to REPORT which libs fail
-- to load, so it loads each one in a pcall and survives casualties. This one ASSERTS,
-- because its callers cannot proceed without the stack. Different jobs, not a third copy.
--
-- Usage:  local ACE = assert(loadfile(SMOKE .. [[ace_stack.lua]]))()
--         ACE.Load(LIBS)     -- returns the number of files loaded

local M = {}

local function load(path)
    local chunk = assert(loadfile(path), "cannot load " .. path)
    assert(pcall(chunk, "COA_DungeonRun", {}))
end

-- ★ LibStub FIRST; everything after it asks for itself by name and would silently
-- register nothing without it.
local ORDER = {
    [[LibStub\LibStub.lua]],
    [[CallbackHandler-1.0\CallbackHandler-1.0.lua]],
    [[AceGUI-3.0\AceGUI-3.0.lua]],
}

-- ★ AceConfig's two halves come AFTER every widget: the Dialog turns an option table into
-- widgets, so it needs the widget types registered before anything asks it to draw.
local AFTER = {
    [[AceConfig-3.0\AceConfigRegistry-3.0\AceConfigRegistry-3.0.lua]],
    [[AceConfig-3.0\AceConfigDialog-3.0\AceConfigDialog-3.0.lua]],
}

-- ⚠ THE WIDGET LIST IS READ FROM DISK, NEVER LISTED HERE. A hand-listed set is a claim
-- about the Libs folder that stops being true the moment a file is added, and it fails by
-- a widget type simply not existing - which reads as an addon bug, not a harness gap.
function M.Load(LIBS)
    local n = 0
    for _, p in ipairs(ORDER) do load(LIBS .. p); n = n + 1 end

    local widgets, wf = {}, io.popen('dir /b "' .. LIBS .. 'AceGUI-3.0\\widgets\\*.lua" 2>nul')
    if wf then
        for line in wf:lines() do widgets[#widgets + 1] = line end
        wf:close()
    end
    -- Sorted so the load order is the same on every run; two widgets that collide would
    -- otherwise collide differently each time and the failure would look intermittent.
    table.sort(widgets)
    for _, w in ipairs(widgets) do load(LIBS .. [[AceGUI-3.0\widgets\]] .. w); n = n + 1 end

    assert(#widgets > 0, "NO ACEGUI WIDGETS LOADED: the widgets folder read empty, which "
           .. "means every Create() below is about to return nil and every assertion "
           .. "about a widget is about to test the harness instead of the addon")

    for _, p in ipairs(AFTER) do load(LIBS .. p); n = n + 1 end
    return n
end

return M
