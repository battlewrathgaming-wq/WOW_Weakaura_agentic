-- range_run.lua - run the declared walk and print it as TSV.
--
-- ★ It loads `COA_DevDump/sheet_decl.lua` and `COA_DevDump/range_walk.lua` DIRECTLY - the same two
-- files the client loads. There is no offline copy of either, so a disagreement between this and a
-- capture is a fact about the two Lua interpreters and never about two implementations.
--
--     stdout   i <TAB> op <TAB> envLo <TAB> envHi <TAB> breadth <TAB> at <TAB> step <TAB> n <TAB> sel

local ROOT = "addons/COA_DevDump/"
local decl = assert(loadfile(ROOT .. "sheet_decl.lua"), "sheet_decl.lua not loadable")
decl()
local walk = assert(loadfile(ROOT .. "range_walk.lua"), "range_walk.lua not loadable")
walk()

local steps, err = COA_RANGE_WALK.Run(COA_UI_SHEET)
if not steps then
    io.stderr:write(tostring(err or "the walk produced nothing") .. "\n")
    os.exit(1)
end

local out = {}
for i = 1, #steps do
    local r = steps[i]
    out[#out + 1] = string.format("%d\t%s\t%d\t%d\t%d\t%d\t%d\t%d\t%s\t%s",
        r.i, r.op, r.envLo, r.envHi, r.breadth, r.at, r.step, r.n,
        table.concat(r.sel, ","), tostring(r.clamped))
end
io.write(table.concat(out, "\n"))
