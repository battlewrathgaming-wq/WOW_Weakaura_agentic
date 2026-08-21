-- COA_DungeonRun smoke helper - THE SHIPPED VOCABULARY, READ RATHER THAN COPIED.
--
-- ★★★ THIS FILE EXISTS BECAUSE A COPY DRIFTS AND A READ CANNOT.
--
-- §457: `smoke_bucket`'s stub adaptor was MORE PERMISSIVE than the shipped one, and hid
-- a gate reading the wrong table for four commits - three of four authorable actions
-- would not have built in the client.
-- §458: the stub was fixed by COPYING `SENSE_WORDS` and `ROW_ACTIONS` correctly. One
-- commit later a new gate read `ROW_ARG`, which the copy did not have, so the gate was
-- **inert and the suite was green**. ★ The lesson was not forgotten - it arrived in a
-- shape the fix did not cover, and only a READ covers every future shape.
--
-- ⚠ `routes.lua` takes `ADDON, NS` as varargs and writes `NS.Routes`, so it needs
-- `loadfile` and an explicit call rather than `dofile`. It touches nothing else at load
-- time - `Store` is resolved later, in `Init` - which is what makes this safe.
--
-- ⚠ IT RETURNS THE SHIPPED TABLES THEMSELVES, not clones. A smoke that mutated one
-- would be authoring the client's vocabulary; none does, and a clone would reintroduce
-- exactly the drift this file removes.

local here = debug.getinfo(1, "S").source:match("@(.*[/\\])") or ""

local ns = {}
local chunk = assert(loadfile(here .. "../../COA_DungeonRun/routes.lua"),
                     "routes.lua would not load - the smoke vocabulary reads it directly")
assert(pcall(chunk, "COA_DungeonRun", ns))
local R = assert(ns.Routes, "routes.lua loaded but published no Routes")

-- ⚠ NAMED, so a table RENAMED upstream fails here rather than arriving as nil and
-- turning a gate off. That is the §458 failure verbatim, and this line is its guard.
return {
    SENSE_WORDS = assert(R.SENSE_WORDS, "routes.lua no longer publishes SENSE_WORDS"),
    ROW_ACTIONS = assert(R.ROW_ACTIONS, "routes.lua no longer publishes ROW_ACTIONS"),
    ROW_ARG     = assert(R.ROW_ARG,     "routes.lua no longer publishes ROW_ARG"),
}
