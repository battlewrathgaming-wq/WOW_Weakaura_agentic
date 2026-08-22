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
local out = {
    SENSE_WORDS = assert(R.SENSE_WORDS, "routes.lua no longer publishes SENSE_WORDS"),
    ROW_ACTIONS = assert(R.ROW_ACTIONS, "routes.lua no longer publishes ROW_ACTIONS"),
    ROW_ARG     = assert(R.ROW_ARG,     "routes.lua no longer publishes ROW_ARG"),
    -- ★ B3's declaration. ⚠ Named like the rest so a RENAME upstream fails HERE on its
    -- own line rather than arriving as nil and switching the arg guard off - which is
    -- §458's failure verbatim, and the reason this file exists.
    ROW_ARG_RULE = assert(R.ROW_ARG_RULE, "routes.lua no longer publishes ROW_ARG_RULE"),
    ARG_MAX      = assert(R.ARG_MAX,      "routes.lua no longer publishes ARG_MAX"),
    -- ★★ THE POSITION RULE TRAVELS TOO, and it is a FUNCTION rather than a table. A stub
    -- that reimplemented *"is this node a position in the sequence"* would be a second
    -- copy of the one rule AL-19 exists to put in one place - and a second copy is what
    -- this file was written to stop.
    IsPosition  = assert(R.IsPosition, "routes.lua no longer publishes IsPosition"),
    LedTo       = assert(R.LedTo,      "routes.lua no longer publishes LedTo"),
}

-- ★★★ AND NOTHING UPSTREAM MAY BE LEFT OUT — the half the named asserts do not cover.
--
-- ⚠⚠ THIS FILE WAS WRITTEN TO STOP §458 AND §465 HAPPENED ANYWAY: `routes.lua` grew
-- `ROW_ARG_RULE`, the stubs never took it, and BUCKET's brand-new arg guard read a nil
-- table and passed EVERYTHING. The suite was green over three fixtures that must be
-- refused - **the same inert-guard shape, for the third time in three days.**
--
-- ★ The named asserts above catch a RENAME. They cannot catch an OMISSION, because a
-- name nobody wrote down is a name nobody checks. ⟶ So this walks what `routes.lua`
-- actually publishes and refuses to hand back a partial vocabulary.
--
-- ⚠ The pattern is deliberately mechanical rather than a hand-kept list, because a
-- hand-kept list is the thing that was already forgotten once.
for k in pairs(R) do
    if type(k) == "string"
       and (k:match("^ROW_") or k:match("_WORDS$") or k:match("^ARG_")) then
        assert(out[k] ~= nil,
               "`routes.lua` publishes `" .. k .. "` and this file does not hand it to "
               .. "the smokes. A stub missing a table the shipped code reads makes any "
               .. "guard built on it INERT and the suite green - §457, §458 and §465 are "
               .. "three instances of exactly that. Add it above.")
    end
end

return out
