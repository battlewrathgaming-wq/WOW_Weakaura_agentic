-- Model: addons/planning/DRIVER_BASIS.md
--
-- ★★★ THE ROUTE CONTRACT (A11.1a, P2) — the flat record shape, declared ONCE.
--
-- A11.1a: *"The flat row is declared in ONE file both sides cite (producer = the
-- flattener when it exists; consumer = the driver)."* This is that file.
--
-- ⚠⚠ IT IS LUA AND NOT MARKDOWN, and that is the whole design. A prose contract is a
-- thing two implementations read differently and a check cannot read at all. Here the
-- shape is DATA: the producer builds from it, the driver reads against it, and
-- `smoke_contract.lua` asserts properties OF it. A11.1's own mutation — *"drop
-- `ordinal` from the contract → the contract check fails"* — is only mechanical if the
-- contract is machine-readable.
--
-- ⚠ NOT `DRIVER_CONTRACT.md`, which is already taken and is about something else
-- entirely (what we consume from `AscensionUI.DeathRecap`).
--
-- ★ WHAT THIS FILE DOES NOT DO. It declares no behaviour, reads no store and builds
-- nothing. A11.1b forbids the driver reaching for `Routes.*` / `Store.*`, and a
-- contract that imported either would hand it the reference in the first line.
--
-- ═════════════════════════════════════════════════════════════════════════════
-- THE SHAPE, from `driver_data_model.md` §A1 — TWO RECORD KINDS, both keyed by the
-- address. ⚠ CITED, never restated: A11.1a's brief was itself corrected for carrying
-- a second copy of the line, because "an acceptance brief that restates what a
-- governing document settles is a second copy that can disagree with the first".
-- What is below is the FIELD LIST in code form, which is the one thing a governing
-- markdown cannot be.
-- ═════════════════════════════════════════════════════════════════════════════

local NS = select(2, ...)
NS = NS or _G.COA_DungeonRun_NS or {}
if select(2, ...) == nil then _G.COA_DungeonRun_NS = NS end

local Contract = {}
NS.Contract = Contract

-- ★ THE CONTENT VERSION, distinct from the ENCODE version. `driver_data_model.md`
-- §A4 17a puts a VERSION PREFIX on the transport; RI-21 D5 records why the two are
-- separate questions — the encoding and the content rev at different rates, and
-- collapsing them makes every content change cost an encoding rev.
Contract.VERSION = 1

-- ★★ FIELD TYPES ARE DECLARED, and this is what makes A11.1c checkable rather than
-- asserted. RI-18: *"identifiers and numbers only — no free text anywhere"*, `arg`
-- included, because a line with nothing to escape has no reserved character to defend.
--
-- ⚠ There is deliberately NO "text" type. A11.1c says a smoke must go red *"the day a
-- label is put back into a payload"* — so the vocabulary itself has to lack the word.
-- Adding one is then a visible act in this file rather than a quiet field somewhere.
Contract.TYPES = {
    id     = "an identifier minted by us - RID, BID, CID, NoteID, a config index",
    number = "a number the rule computes with - a coordinate, a radius, a stage",
}

-- THE ADDRESS. Both record kinds carry it whole: `driver_data_model.md` §A1.2 -
-- *"ownership is the address; there is no ownership table"*, because an ownership
-- table is the only structure that could disagree with the tree it describes.
Contract.ADDRESS = {
    { name = "mapID", type = "id",     why = "the gate; bucketable at ingest" },
    { name = "rid",   type = "id",     why = "the route; re-mints on import (RI-4)" },
    { name = "bid",   type = "id",     why = "the beacon; carries unchanged on import" },
    { name = "cid",   type = "id",     optional = true,
      why = "the child. ABSENT on a beacon's OWN record - a beacon carries a reach "
         .. "and a stage of its own (G2, §299), so the address stops at BID" },
}

-- THE CHARACTERISTIC RECORD — one per node. §A1.1.
Contract.CHARACTERISTIC = {
    { name = "stage",    type = "number", zeroMeans = "always eligible",
      why = "the lock-out gate. 0 is a VALUE, never a blank slot (§385c): nil in the "
         .. "STORE, 0 on the RECORD, one meaning - no gate" },
    -- ⚠ NO `seed`: a minted child takes `Routes.NextOrdinal(b)`, which is COMPUTED from
    -- what already exists. A seed is a constant an author did not pick; a next-in-sequence
    -- is a function of the route, and writing a number here would be neither.
    { name = "step",     type = "number", zeroMeans = "always eligible",
      why = "the child ordinal. Same 0 rule; an un-ordinalled child is out of the "
         .. "line on purpose (routes.lua:566)" },
    { name = "posX",     type = "number", why = "WORLD x - never MAP xy (map.lua:46)" },
    { name = "posY",     type = "number", why = "WORLD y" },
    { name = "posZ",     type = "number", why = "WORLD z" },
    { name = "r",        type = "number", why = "the radius" },
    { name = "band",     type = "number", seed = 2.5,
      why = "UPWARD ONLY since RI-22 - one value, not a pair. A captured sample IS "
         .. "the floor (ROUTER 280), so downward tolerance measures nothing" },
    { name = "nextType", type = "id",     why = "Step | Stage | Set - ONE field, two slots" },
    { name = "nextArg",  type = "number", optional = true,
      why = "present only for Set(N); the slot is EMITTED EMPTY for Step/Stage rather "
         .. "than omitted, so positions never shift (RI-18 Q3)" },
    -- ⚠ NO `seed` HERE, DELIBERATELY, and the row beneath it HAS one. The node-level
    -- latch has no code term chosen yet, so a seed would be this file inventing the value
    -- the control will offer - which is the one thing a declaration must not do.
    -- ★★★ THE WAYPOINT TICK (AL-19), DECLARED §715 — AND IT WAS ALREADY LIVE.
    --
    -- ⚠⚠ THIS IS THE INVERSE OF THE `nextType` CASE. There the DECLARATION was ahead of the
    -- store (§709, AL-21). Here the STORE was ahead of the declaration: `bucket.lua:507`
    -- writes `ledTo` onto every entry, `manager.lua:265` reads it to choose the lure, and
    -- `Routes.LedTo` resolves it - while `contract.lua` had **never heard of the field.**
    -- Measured §715: `ledTo` appeared 0 times here and 4 times in the shipped code.
    --
    -- ★ SO THIS RECORDS WHAT IS TRUE rather than adding something. AL-19 moved `supertrack`
    -- out of the closed action list and made it a node characteristic; the characteristic was
    -- never written down, so §4d's standing bound - *"a control with no record field does not
    -- belong"* - was blocking a control whose field had existed all along.
    --
    -- ★★ A CHARACTERISTIC, NOT IDENTITY (Battlewrath, 2026-08-27): *"identity = intrinsic.
    -- Characteristics are mutable."* The address above is intrinsic and minted once; this is a
    -- tick an author flips, so it belongs here and nowhere else.
    --
    -- ⚠ OPTIONAL because the default stores nothing (§79): absent is ON. A stored field whose
    -- only meaning is *"I did not choose"* is residue, and residue TRAVELS in an export.
    { name = "ledTo",    type = "id",     optional = true,
      why = "the waypoint tick (AL-19). Absent is ON; only an author's OFF is written. "
         .. "⚠ The RUN-time answer is `Routes.LedTo`, which gates on `IsPosition` FIRST - a "
         .. "tray-0 node is never led to whatever this says" },

    { name = "trigger",  type = "id",     optional = true,
      why = "a NODE field, not a row field (2026-08-19). ⚠ The once|every control is "
         .. "NOT BUILT and no code term is chosen - the slot is declared so the shape "
         .. "does not move when it lands" },
}

-- THE BEHAVIOUR RECORD — N per node, one per action tab. §A1.1.
Contract.BEHAVIOUR = {
    { name = "sense",  type = "id", why = "whenOn | seen | whenOff - the floor words" },
    -- ★★★ OPTIONAL (AL-18). `When on` with NO action means REACHED - arrival IS the
    -- behaviour of a placed node, and an action is what ELSE happens there. ⚠ It was
    -- REQUIRED here until §476, and nothing caught it because no fixture carried an
    -- arrival row until AL-19 retired `supertrack` and one had to.
    -- ★★ THE PER-TAB LATCH (AL-23). A row latches on COMPLETION; `every` releases it
    -- when the sense drops, `once` leaves it spent until the NODE re-arms.
    -- ⚠ Optional because the default stores nothing (§79) - absent is `once`.
    { name = "trigger", type = "id", optional = true, seed = "once",
      why = "once | every - the ROW's latch; absent is once (AL-23)" },
    { name = "action", type = "id", optional = true,
      why = "the action function's word; ABSENT means the row is arrival alone (AL-18)" },
    { name = "arg",    type = "id", optional = true,
      why = "AN ID REFERENCE, never free text - a boss NAME is an index into the "
         .. "shipped names table, so the record carries no string to escape" },
}

-- ★ THE TWO SIDE TABLES THE DRIVER NEVER OPENS (RI-18, §A2.6). Declared here so the
-- producer and the driver agree they exist and agree the driver ignores them.
-- ⚠ Each has exactly ONE free field and it is LAST after its key, which is the only
-- place free text lives at all.
Contract.SIDE_TABLES = {
    names = "MapID · RID:Name · RID:BID:Name · RID:BID:CID:Name",
    notes = "RID:BID:CID:NoteID : content",
}

-- ★ THE COORDINATE SPACE, stated because getting it wrong is silent. `map.lua:46`
-- carries two sizes and MAP xy is the wrong one by +2.2% across and +15% down - a
-- trail that follows corridors and is wrong everywhere. A11.1's own mutation feeds a
-- row in MAP xy and expects the fixture's known-world target NOT to fire.
Contract.SPACE = "WORLD"

-- ⚠ COMPOSED AT EXPORT, not stored: `stage` and `step` are PROPERTIES and move when an
-- author restages, so a stored key made of them re-keys a note on every reorder
-- (§A3.11). Declared here so a producer knows to compute them and a reader knows not
-- to expect them in the store.
Contract.COMPOSED = { "stage", "step" }

-- ★★★ THE SEED IS THE VALUE AN AUTHOR GETS BY CHOOSING NOTHING, and it lives HERE
-- because this file already declares every field's type, its optional-ness, its
-- zero-meaning and its why. RI-53 measured that of 14 module constants only TWO were
-- defaults, so a separate defaults store would be a new home for a fact this one already
-- holds the shape of.
--
-- ⚠⚠ A SEED IS NOT A BOUND AND NOT A COMPUTATION, and only the literals moved:
--     `band`     2.5  — moved OUT of `bucket.lua`, which now READS it. One home.
--     `trigger`  once — AL-23's *absent is once*, a literal with nowhere else to live.
--     `r`        NOT MOVED. `Routes.R_FLOOR` is a FLOOR - a bound that also happens to be
--                what a mint uses - and it is clamped against elsewhere. Copying it here
--                would create the second copy this whole item exists to remove.
--     `step`     NOT MOVED. Computed per route; see its entry.
-- ⟶ Where a value already has an owner, this file POINTS rather than copies. That is the
-- same rule the concept homes run on: a home is an INDEX, never a second copy (AL-26).
--
-- ★ READ IT, never restate it. `Contract.Seed("behaviour", "trigger")` is one call; a
-- consumer holding its own `local ONCE = "once"` is the drift this replaces.
function Contract.Seed(kind, name)
    for _, f in ipairs(Contract.Fields(kind) or {}) do
        if f.name == name then return f.seed end
    end
    return nil
end

function Contract.Fields(kind)
    local body = kind == "behaviour" and Contract.BEHAVIOUR or Contract.CHARACTERISTIC
    local out = {}
    for _, f in ipairs(Contract.ADDRESS) do out[#out + 1] = f end
    for _, f in ipairs(body) do out[#out + 1] = f end
    return out
end

-- ★ ONE PLACE ANSWERS "is this field allowed to be absent". A producer emitting an
-- empty slot and a reader accepting one must agree, and the disagreement is silent.
function Contract.Optional(kind, name)
    for _, f in ipairs(Contract.Fields(kind)) do
        if f.name == name then return f.optional == true end
    end
    return nil                      -- ⚠ nil means NOT A FIELD, which is not `false`
end

return Contract
