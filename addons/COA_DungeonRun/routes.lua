-- COA_DungeonRun routes.lua - THE PROMOTED OBJECTS.
--
-- Model: addons/planning/DRIVER_BASIS.md   READ FIRST. It names what governs NOW, in
--        precedence order, and it MOVES when a ruling moves - so this line never
--        goes stale. Lower number wins; a disagreement is reported, not resolved here.
-- Record: addons/planning/ARCHIVE__dungeonrun_poc.md §29, §56, §60, §61, §62
--         how it was argued. A RECORD, never a target.
--
-- ---------------------------------------------------------------------------
-- ★ THE SECOND DATA FORM, and it is independent of the first.
--
-- A run is EVIDENCE: what happened, as captured, never edited (DR-9). A route is
-- an AUTHORED OBJECT: what someone decided the dungeon should be run as. §29 says
-- promotion COPIES - so once a beacon exists it owes its origin nothing, and the
-- §25.2 back-reference is DROPPED (§61): a beacon is expected to drift from the
-- node it came from as methods improve, there is nothing to authenticate, and a
-- route is DATA rather than code - a plot table - so a bad one is a quality
-- problem, not a trust one.
--
-- The consequence is the good kind: an exported route needs nothing from the run
-- it was born from, because it never referenced it.
--
-- ★ WHAT CARRIES OVER, AND WHAT DOES NOT. The one rule, stated once:
--
--     PLACE carries.      x,y,z · mapX,mapY,mapZ · floor · mapID
--     EVENT does not.     t,gt · kind · n · combat · dead · killedBy · ghost
--
-- A beacon is a statement about a SPOT. When that pull happened, what it was, and
-- who killed you there are facts about a capture - true of the run, not of the
-- place - and copying them would make the beacon assert things it cannot know for
-- the next person to stand there. §60: origin is gated, POSITION IS NOT.
--
-- `z` in particular is INHERITED AND NEVER COMPUTED (§25.2). It is a teacher: drag
-- a beacon across the map later and it keeps the height it was born at, so a
-- beacon floating at the wrong height is the design telling you something.
--
-- ★ DR-20 STILL HOLDS. store.lua owns COA_DungeonRunDB and hands us our sub-tables
-- through Store.RouteTable/NoteTable; this file owns the SHAPE of what lives under
-- those keys. So there is still exactly one module that touches the global, and
-- DR-21's schema refusal covers routes for free rather than needing a second copy.
-- ---------------------------------------------------------------------------

local ADDON, NS = ...

local Routes = {}
NS.Routes = Routes

local Store

-- ⚠ The migration runs HERE rather than in `Store.Load`, because store owns the global
-- and this file owns the SHAPE of what lives under `routes` (DR-20). `core.lua` calls
-- every Init after all files have loaded, so Store is present by now.
function Routes.Init()
    Store = NS.Store
    if Store and Store.fromSchema then Routes.MigrateRIDs() end
    -- ★★ THE ORDER IS LOAD-BEARING, AND IT IS ONE RULE: **migrate before you retire.**
    -- `DropRetired` sweeping a field the migration still needs to read would delete the
    -- author's work on the same load that would have converted it. ⟶ Both of this
    -- session's ordering hazards are the same shape - a clean-out running before the
    -- thing that needs the data.
    Routes.MigrateRows()
    Routes.DropRetired()
end

-- ★★★ RULING: PLACE carries, EVENT does not - a beacon is a statement about a SPOT
-- ★ PLACE, and nothing else. Written as an explicit whitelist rather than a copy
-- with deletions: a field added to capture tomorrow must be a DECISION to carry,
-- not something that arrives by default. The failure mode of the other direction
-- is silent - the beacon simply starts asserting a new fact nobody chose.
local PLACE = { "x", "y", "z", "mapX", "mapY", "mapC", "mapZ", "mapID", "floor" }

function Routes.Inherit(node)
    if not node then return nil end
    local out = {}
    for _, k in ipairs(PLACE) do out[k] = node[k] end
    return out
end

-- What the promoter SHOWS before you commit - the same move as the map strip
-- naming the tile file. A borrow shown rather than assumed, and it pre-empts the
-- z question by letting you watch z arrive from the node.
function Routes.InheritSummary(node)
    if not node then return "no node selected" end
    local p = Routes.Inherit(node)
    if not p.mapX then return "the selected node has no map position - it cannot be placed" end
    return ("x %.2f  y %.2f  z %s  ·  floor %s"):format(
        p.mapX, p.mapY,
        p.z and ("%.1f"):format(p.z) or "-",
        tostring(p.floor or 0))
end

-- ---------------------------------------------------------------------
-- Routes (the family)
-- ---------------------------------------------------------------------
--
-- ★ §60: A ROUTE IS VALID FOR A MAPID, NOT A DIFFICULTY. His ruling - "a route may
-- hold useful from mythic to mythic +5" - so the object says which DUNGEON it is
-- for and says nothing about how hard it was when authored. Difficulty is run
-- identity (DR-30); it is not route identity.

local function tbl() return Store and Store.RouteTable() or nil end

-- ★★★ A8.4 (§335): `composeId` IS GONE, not parked. It built the route's key as
-- `<name>-<n>`, and two faults came out of that one line: the KEY carried a label
-- that `Rename` could change and never did, and it could contain a COLON - the very
-- character `RID:BID:CID` uses to separate segments. A route named "SFK: fast"
-- produced the unparseable address "SFK: fast-3:4:1".
--
-- ⚠ Removed rather than left unused: a half-formed path invites building on it, and
-- an id-composer sitting beside an id-free Create is exactly the thing the next
-- reader reaches for. ⚠ `store.lua` keeps its OWN composeId for RUNS - untouched,
-- deliberately, because a run id is not an address segment.

-- Same id/name separation as a run (Store.Open): the name is stored AS TYPED and
-- uniqueness comes from the counter alone, so renaming moves a label and no handle.
function Routes.Create(name, mapID)
    local t = tbl()
    if not t then return nil end
    -- ★ THE KEY IS THE RID AND NOTHING ELSE. The name is free text from here on -
    -- rename it to anything, colons included, and the address is untouched.
    -- ⚠ And the rid is NOT also stored on the route: the key IS the identity, and a
    -- second copy is a thing that can disagree with the first (M3).
    local id = (Store.NextRouteId and Store.NextRouteId()) or 1
    t[id] = {
        name    = name or "",
        mapID   = mapID,
        -- ★★★ 17d (RI-24 drained 2026-08-20, §404): NOTHING SCRAPED ABOUT THE
        -- CHARACTER TRAVELS. `author = UnitName("player")` stood here and it was not
        -- speculative, it was WRONGLY SOURCED - shipping it in an export is a
        -- disclosure the author never made. Battlewrath: *"That's for the user to
        -- disclose what characters they play."* Same law as RI-4's "the origin on
        -- someone else's data does not travel", and the same manners the bench holds
        -- on the client: read-only on data that is not ours.
        --
        -- ⚠ `madeAt = time()` goes WITH it rather than separately. The replacement is
        -- one surface - who / when / author notes, all typed or left empty - so
        -- keeping the clock reading would be half a retirement, which is the shape
        -- §402 just finished arguing against. A route carries a NAME today and
        -- nothing else that is not attached to a beacon.
        --
        -- ⚠⚠ AND THE SURFACE DOES NOT EXIST YET. Neither A10.3's node editor nor a
        -- route-level pane owns it (Battlewrath, 2026-08-20: *"these don't exist
        -- yet"*), so this removes the wrong source WITHOUT inventing the right one.
        -- Whoever builds the metadata pane adds the three fields there.
        beacons = {},
    }
    return id, t[id]
end

function Routes.Get(id)
    local t = tbl()
    return (t and id) and t[id] or nil
end

function Routes.Rename(id, name)
    local r = Routes.Get(id)
    if not r or type(name) ~= "string" then return nil end
    r.name = name:match("^%s*(.-)%s*$")
    return r.name
end

function Routes.Delete(id)
    local t = tbl()
    if t and id then t[id] = nil end
end

function Routes.Ids()
    local out = {}
    for id in pairs(tbl() or {}) do out[#out + 1] = id end
    table.sort(out)
    return out
end

-- ★★ ROUTES ARE OFFERED ONLY FOR THE MAP THAT IS LOADED. Battlewrath, 2026-08-14:
-- *"Routes, on creation, are on that map that's loaded. And are offered to load
-- only for the map that is loaded."*
--
-- ★ THIS IS A FILTER, NOT §36'S SORT, and the difference is which fact is doing the
-- work. §36 says LOCATION sorts and never picks - because where your body happens
-- to be is not a choice you made about what to work on. The loaded map IS that
-- choice. So offering a route for another dungeon is not helpfulness, it is
-- offering to draw beacons onto art they were never placed against - which, being
-- placed by fraction, would look like a plausible route rather than like an error.
--
-- Nothing loaded means no map, which means nothing to offer. The authoring surface
-- has nothing to work on, and says so instead of listing everything.
-- ---------------------------------------------------------------------
-- ★★★ A8.4's MIGRATION - old `<name>-<n>` keys to the opaque RID (§335)
-- ★★ A2.6 (§340): A STORED `goTo` OR `onRamp` IS DROPPED, AND SAID.
--
-- The acceptance is explicit: *"any stored `goTo` on an existing route is TOLD at
-- load and dropped, NEVER SILENTLY HONOURED."* ⚠ Silently honouring it is the worse
-- of the two failures - a route would keep redirecting through a mechanism nothing
-- else in the build knows about, and the author would have no way to find out why.
--
-- ★ And it is TOLD rather than refused, which is the same S4 line the rest of the
-- editor holds: the author is not stopped, they are informed that a thing they
-- authored no longer exists. Their route still runs; it runs by ordinal now.
--
-- ⚠ This runs on EVERY load, not only a migration. A `goTo` can arrive from a
-- hand-edited SavedVariables or an import written against an older build, and
-- neither of those bumps a schema version.
--
-- ★★ A2.12b (§392) ADDS `fireOn` HERE - the same function, one more field in the
-- condition, because the reason is identical: a withdrawn mechanism can arrive from
-- a file this build never wrote.
--
-- ⚠⚠ AND IT COUNTS AND SAYS SEPARATELY, which is the only part worth arguing about.
-- Folding it into `dropped` would have been three characters less and would have
-- announced a "retired POINTER" for a field that never pointed at anything. ★ A
-- message that misdescribes what it dropped is worse than no message: the author
-- goes looking for a redirect they never authored. The criterion is the MESSAGE
-- (A2.12b's mutation bites on a silent drop), so the message has to be TRUE.
-- ★★ AN ARG ON AN ACTION THAT TAKES NONE, stripped through the same door (§460).
--
-- `ROW_ARG` is *"the one place that knows"* which actions take an arg; its own comment
-- rules the case exactly - *"`nil` means the action takes nothing, **not that anything is
-- allowed**"*. ⟶ A stray one can only arrive the way `goTo` does, and the sentence above
-- names both sources: a hand-edited SavedVariables or an import written against another
-- build. Neither bumps a schema version, so this runs on every load like the rest.
--
-- ⚠ ONLY FOR A KNOWN ACTION. An unknown action's arg is left exactly where it is: the
-- action itself is the foreign thing, and stripping its arg would make the row LOOK
-- authorable while still being refused at build (§457, by name). ★ Half-retiring a row is
-- the shape that invites building on it.
--
-- ⚠⚠ `Routes.RowsOf` IS NOT USED HERE, deliberately: it MATERIALISES `rows = {}` as a
-- side effect, so a sweep built on it would write an empty table onto every beacon and
-- every child of every route, on every load - a clean-out that dirties the file it walks.
--
-- ⚠ `has()` is NOT in scope at this point in the file - it is declared ~900 lines below,
-- so the bare name resolves to a nil GLOBAL here. `Routes.ROW_ACTIONS` reaches the same
-- list through an upvalue that IS in scope, and is read at CALL time. (Confirmed by
-- running it, not by reading it.)
local function strayArgs(holder)
    local n = 0
    for _, row in ipairs(holder and holder.rows or {}) do
        if row.arg ~= nil and Routes.ROW_ARG[row.action] == nil then
            local known = false
            for _, w in ipairs(Routes.ROW_ACTIONS) do
                if w == row.action then known = true end
            end
            if known then
                row.arg = nil
                n = n + 1
            end
        end
    end
    return n
end

-- =====================================================================
-- ★★★ B1 (AL-17) · THE FLAT FORM BECOMES ROWS — MIGRATED ONCE, AND TOLD.
--
-- **`child.rows` IS the instruction set** (data model A1.1: the BEHAVIOUR record is
-- `Sense : action : arg`, and A1.1's own note says the Trigger move *"makes the BEHAVIOUR
-- record and the ruled grammar the same thing"*). The pane writes `sense` / `action` /
-- `boss` — the older shape — and **nothing converted**, so a route authored through the
-- shipped doors reached BUCKET with zero rows and stalled in silence (§462's probe).
--
-- ⚠⚠ MIGRATED, NOT CONVERTED AT BUILD, and AL-17 gives the reason: converting at build
-- would keep TWO AUTHORED TRUTHS alive — the flat fields and the rows — and a second copy
-- is a thing that can disagree with the first. One migration leaves one truth.
--
-- ★ THE MAPPING IS SMALL BECAUSE THE FLAT VOCABULARY IS: `Routes.ACTIONS` is
-- `{ "supertrack" }` and `Routes.SENSES` is EMPTY (its emptiness is a ruling, RI-15/17),
-- so the only flat states are *a supertrack*, *a boss name*, or *neither*. The sense is
-- always `reachHere` — arrival — which is `whenOn` in the row grammar.
--
-- ⚠⚠ IT MIGRATES ONLY A NODE WITH NO ROWS. That is what makes it idempotent across the
-- every-load call, and it is also the rule that decides the collision: **once rows exist,
-- the rows are the truth.** ★ The window this leaves is REAL and named rather than papered
-- over: until L1.4 moves the pane onto rows, a pane edit still writes a flat field that
-- this will not pick up, because the node already has rows. That is why the Analyst
-- sequenced **B1 before L1.4**, and why the flat fields are NOT retired here — sweeping
-- them while the pane still writes them would delete the author's work mid-session.
-- ⟶ **Migrate before you retire; retire when L1.4 lands.**
--
-- ⚠ `Routes.RowsOf` IS NOT USED - it MATERIALISES `rows = {}` as a side effect, so a
-- sweep built on it would write an empty table onto every node on every load, and worse,
-- would make "has no rows" impossible to ask. Same reason `DropRetired` avoids it (§460).
-- =====================================================================
-- ★★★ A STORED `supertrack` BECOMES THE TICK, NOT A ROW (AL-19).
--
-- ⚠⚠ §471's BRANCH WAS WRONG AND THIS CORRECTS IT: it converted a flat `supertrack`
-- into a `When on:supertrack` ROW, which AL-19 then ruled is not a verb at all. ★ The
-- correction was named as a COST in AI-8 before the ruling landed, so it is a planned
-- edit rather than a discovery - and the migration has not reached a player.
--
-- ⚠ IT TAKES BOTH SHAPES, because this repo already ran §471's version: a flat
-- `x.action == "supertrack"` AND an already-migrated `whenOn:supertrack` ROW both become
-- the tick. A dev store carrying the intermediate shape must not be stranded.
--
-- ★ AND THE TICK IT SETS IS **NOTHING**: `supertrack` chosen means LED TO, which is the
-- DEFAULT, and §79's rule is that the default stores nothing. So the conversion is a
-- DROP - the author's choice and the default agree, and the node takes the arrival seed.
local function untrack(x)
    local moved = 0
    if x.action == "supertrack" then
        x.action = nil
        moved = moved + 1
    end
    for i = #(x.rows or {}), 1, -1 do
        if x.rows[i].action == "supertrack" then
            -- ⚠ THE WHOLE ROW GOES, not just its action. A `whenOn` row with the action
            -- stripped is the arrival SEED, and leaving one per migrated node would mint a
            -- duplicate seed the moment `RowsOf` is asked. ★ Removing it lets the seed do
            -- its own job - there is exactly one door that creates one.
            table.remove(x.rows, i)
            moved = moved + 1
        end
    end
    return moved
end

local function migrateNode(x)
    if not x then return 0 end
    local moved = untrack(x)
    if x.rows and #x.rows > 0 then return moved end
    local rows = {}

    -- ★ ORDER IS FIXED AND STATED: the placement behaviour first, then the listener. A
    -- row is a SERIES OF SLOTS IN FIXED POSITIONS (Battlewrath, 2026-08-21) and the ROWS
    -- are a sequence too - nothing downstream depends on this order, but a migration that
    -- produced a different order per run would make two saved files disagree for no reason.
    if x.action ~= nil then
        rows[#rows + 1] = { sense = "whenOn", action = x.action }
    end
    if x.boss ~= nil and x.boss ~= "" then
        rows[#rows + 1] = { sense = "whenOn", action = "boss", arg = x.boss }
    end

    if #rows == 0 then return moved end
    x.rows = rows
    return moved + #rows
end

function Routes.MigrateRows()
    local t = tbl()
    if not t then return 0 end
    local made = 0
    for _, r in pairs(t) do
        for _, b in ipairs(r.beacons or {}) do
            -- ⚠ BOTH LEVELS. A2.5 returns a child's tabs TO THE PARENT when the last
            -- child goes, so a beacon carries these fields too - and a child-only pass is
            -- the half-migration the `bandDown` sweep already taught this file about.
            made = made + migrateNode(b)
            for _, c in ipairs(b.children or {}) do
                made = made + migrateNode(c)
            end
        end
    end
    if made > 0 then
        NS.Say(("DungeonRun: moved %d authored action(s) - tabs are `When on:action:arg` "
            .. "now (A1.1), and waypointing is the node's LED TO tick rather than a verb "
            .. "(AL-19)"):format(made))
    end
    return made
end

function Routes.DropRetired()
    local t = tbl()
    if not t then return 0 end
    local dropped, fired, banded, scraped, argued = 0, 0, 0, 0, 0
    for _, r in pairs(t) do
        -- ★ 17d: the ROUTE level, which nothing else in this function walks. A stored
        -- `author` is scraped character data sitting in a file that may already have
        -- been exported, so it is dropped on every load like any other retired field
        -- - and SAID, because an author who never chose to disclose it should learn
        -- that it was there.
        if r.author ~= nil or r.madeAt ~= nil then
            r.author, r.madeAt = nil, nil
            scraped = scraped + 1
        end
        for _, b in ipairs(r.beacons or {}) do
            -- ⚠ A BEACON CARRIES A REACH TOO (G2, §299), so the beacon level needs
            -- the same drop. The child loop alone would have left every beacon's
            -- stored `bandDown` in place - a half-retirement, which is the shape
            -- that invites building on it again.
            if b.bandDown ~= nil then
                b.bandDown = nil
                banded = banded + 1
            end
            -- ★ THE BEACON LEVEL, for the same reason the band needed it: A2.5 returns a
            -- child's tabs TO THE PARENT when the last child is deleted, so a beacon
            -- carries rows of its own and a child-only sweep is a half-retirement.
            argued = argued + strayArgs(b)
            for _, c in ipairs(b.children or {}) do
                if c.goTo ~= nil or c.onRamp ~= nil then
                    c.goTo, c.onRamp = nil, nil
                    dropped = dropped + 1
                end
                -- ★ RI-22 (§402): `bandDown` joins for the same reason - a retired
                -- field can arrive from a file this build never wrote.
                if c.bandDown ~= nil then
                    c.bandDown = nil
                    banded = banded + 1
                end
                if c.fireOn ~= nil then
                    c.fireOn = nil
                    fired = fired + 1
                end
                argued = argued + strayArgs(c)
            end
        end
    end
    if dropped > 0 then
        NS.Say(("DungeonRun: dropped a retired pointer from %d child(ren) - routes "
            .. "run by ORDER now, not by pointing (A2.6)"):format(dropped))
    end
    if fired > 0 then
        NS.Say(("DungeonRun: dropped a retired firing field from %d child(ren) - "
            .. "WHEN an action fires is the sense pairing now, not a stored "
            .. "field (RI-5, A2.12)"):format(fired))
    end
    -- ★ ONE TOTAL, because the smoke's contract is "did a load find anything" and
    -- a caller that had to add two numbers could forget one.
    if banded > 0 then
        NS.Say(("DungeonRun: dropped a downward band from %d node(s) - the band is "
            .. "UPWARDS ONLY now, because a captured sample IS the floor "
            .. "(RI-22)"):format(banded))
    end
    if scraped > 0 then
        NS.Say(("DungeonRun: dropped scraped author data from %d route(s) - a "
            .. "character name is yours to disclose, not the addon's to ship "
            .. "(17d)"):format(scraped))
    end
    -- ★ SAID SEPARATELY, and `routes.lua`'s own line above is why: folding this into
    -- another counter would announce the wrong thing, and *"a message that misdescribes
    -- what it dropped is worse than no message"*. ⚠ It names the ACTION's rule rather
    -- than the field, because "dropped an argument" alone leaves the author looking for
    -- which one.
    if argued > 0 then
        NS.Say(("DungeonRun: dropped an argument from %d row(s) - those actions take "
            .. "none, and a field this build never writes is not silently honoured "
            .. "(A2.12b)"):format(argued))
    end
    return dropped + fired + banded + scraped + argued
end

-- ---------------------------------------------------------------------
--
-- Written to `driver_bench_proposition.md` §23's criterion, which was written BEFORE
-- this code. M1-M7 there; the two that carry the weight:
--
--   M1  RECOVERED, NEVER INVENTED. The rid is PARSED out of the old key's tail -
--       `composeId` appended it, so it is already there. ⚠ A key that does not parse
--       is REPORTED and LEFT ALONE. Never given a fresh number: a fresh number is a
--       new identity wearing an old route's name, and nothing downstream could tell.
--   M2  NOTHING LOST. ★ Guaranteed by CONSTRUCTION rather than by copying carefully:
--       the migration moves the REFERENCE, so every field, every beacon, every child
--       and both counters are the same tables afterwards. There is no field list to
--       forget something from.
--
-- ⚠ IT DOES NOT STAMP ON A PARTIAL RUN. If any key could not be parsed the schema
-- stays where it is, so the next load tries again and the report is not lost. A db
-- claiming a shape it does not have is worse than an unmigrated one - the next load
-- would not look.
function Routes.MigrateRIDs()
    local t = tbl()
    if not t then return nil end

    local moved, already, stuck = 0, 0, {}
    local plan = {}
    for k, r in pairs(t) do
        if type(k) == "number" then
            already = already + 1                    -- M5: idempotent
        else
            local n = tostring(k):match("^.*-(%d+)$")
            if not n then
                stuck[#stuck + 1] = tostring(k)      -- M1: reported, left alone
            elseif t[tonumber(n)] ~= nil or plan[tonumber(n)] ~= nil then
                -- ⚠ Two keys parsing to one rid. Cannot happen from `composeId` (the
                -- counter is monotonic) but CAN from a hand-edited SavedVariables,
                -- and overwriting would destroy a route silently.
                stuck[#stuck + 1] = tostring(k) .. " (rid " .. n .. " taken)"
            else
                plan[tonumber(n)] = k
            end
        end
    end

    for rid, old in pairs(plan) do
        t[rid] = t[old]                              -- M2: the same table, moved
        t[old] = nil
        moved = moved + 1
    end

    -- M6: it announces itself. Silence after a migration is indistinguishable from a
    -- migration that did not run.
    if moved > 0 or #stuck > 0 then
        NS.Say(("DungeonRun: %d route(s) moved to opaque ids, %d already, %d left")
            :format(moved, already, #stuck))
        for _, k in ipairs(stuck) do
            NS.Say("  |cffff8080could not read an id from|r " .. k .. " - left as it is")
        end
    end

    -- M7, and ONLY on a clean run.
    if #stuck == 0 and Store.StampSchema then Store.StampSchema() end
    return moved, already, stuck
end

function Routes.List(mapID)
    local out = {}
    if not mapID then return out end
    for _, id in ipairs(Routes.Ids()) do
        local r = Routes.Get(id)
        if r and r.mapID == mapID then
            out[#out + 1] = { id = id, name = (r.name ~= "" and r.name) or id }
        end
    end
    table.sort(out, function(a, b)
        if a.name == b.name then return a.id < b.id end
        return a.name < b.name
    end)
    return out
end

-- ---------------------------------------------------------------------
-- Beacons
-- ---------------------------------------------------------------------
--
-- ★ CREATE THEN EDIT - the house pattern's third appearance (§61). Capture then
-- promote · pin then meaning · mint then author. The beacon exists the moment you
-- press the button, carrying only what it INHERITED; cue, note, radii and icon are
-- edited in-field afterwards. The mechanical part is immediate and the meaning
-- waits, which is also why none of the three needs a dialog.
--
-- ★★★ FACT: [SILENT] stage is a LABEL, not an array index - DeleteBeacon leaves gaps, and 4.1 is ordinary
-- ★ §56: THE SEQUENCE INTEGER RIDES FREE. `stage` is the order the route is run
-- in, assigned as the next number at mint. It is not derived from the node, from
-- time, or from position - it is the author's sequence and nothing else knows it.
-- ★★ §80: THE DEFAULT IS THE LOWEST FREE ROUND NUMBER, not the highest plus one.
--
--   *"The next mint walks the gap. If it's 1,2,3,4,9 it picks up on 5, skips 9 for
--   10, continues."*
--
-- So a gap left by a delete refills itself, and a route the author numbered sparsely
-- on purpose is stepped over rather than collided with. ★ ROUND NUMBERS ONLY - a
-- fraction is never generated, only ever typed: *"the user can always follow up the
-- next mint as 4.2 for their 4.1, but that's them doing something specific."*
function Routes.NextStage(id)
    local r = Routes.Get(id)
    if not r then return 1 end
    -- ⚠ `or 0` IS A NO-OP HERE, MEASURED (RI-43 E2, §451). A stageless beacon marks
    -- `used[0]`, and the search below starts at **n = 1** - so the slot is written and
    -- never read. ★ Left as it is rather than "cleaned": the `or` is what keeps a nil
    -- out of a table key, and removing it would make this line able to throw. **The
    -- conversion is dead, not wrong**, and the pattern sweep should not re-raise it.
    local used = {}
    for _, b in ipairs(r.beacons) do used[b.stage or 0] = true end
    local n = 1
    while used[n] do n = n + 1 end
    return n
end

-- ★ §56 said stage is *"inherited as a default and EDITABLE"*. It was not - AddBeacon
-- assigned #beacons+1 and nothing could change it, so 4.1 could not exist and §79's
-- whole sub-division argument was unreachable in the UI. The mechanism accepted a
-- value nothing could produce; the same shape as §77's ticks.
--
-- ⚠ A DUPLICATE STAGE IS ALLOWED. It is visible in the running order (two rows with
-- the same number, adjacent) and refusing it would be grading the author's work. The
-- consequence is real and theirs: satisfying the first promotes past the second.
-- ★★★ THE BEACON'S ID (§227). Monotonic per route, never reused - the same mint as
-- `nextChildId` and for the same reason, which the address sheets state as a law:
-- a handle must be upstream of everything the user can change.
--
-- ⚠ IT IS A SEPARATE COUNTER FROM THE CHILDREN'S, deliberately. `What am I?` is
-- intrinsic and always available, so TYPE + ID is the full designation and a beacon 1
-- can never be confused with a child 1. Sharing one counter would have bought nothing
-- and forced a migration.
--
-- ★ Battlewrath's scope: *"unique is in the sense of a route."* Nothing references
-- across a route boundary, so route-wide is exactly enough and no more.
local function nextBeaconId(r)
    r.nextBeaconId = (r.nextBeaconId or 0) + 1
    return r.nextBeaconId
end

function Routes.AddBeacon(id, node, stage)
    local r = Routes.Get(id)
    if not r or not node then return nil end
    local b = Routes.Inherit(node)
    if not b or not b.mapX then return nil end     -- unplaceable; refuse rather than store a ghost
    b.kind  = "beacon"
    b.id    = nextBeaconId(r)
    -- ★ THE SAME STANDING R AS A CHILD (A10.3e-R). ⚠⚠ A BEACON NEEDS IT AS MUCH AS A
    -- CHILD DOES and that is not obvious: A2.5 moves a beacon's tabs to child 1 when it
    -- gains children, so a childless beacon IS the node - `lone` - and is refused by name
    -- without a reach. That refusal is what the first test drive hit (2026-08-22).
    b.radius = Routes.R_FLOOR
    -- ⚠ ALWAYS A STAGE. See SetStage's note: the stageless RECOVERY beacon has no
    -- path in through here either. Owed, no impact yet.
    -- ★★★ S7 (§395): 0 IS THE STAGELESS REQUEST, and it is not a new vocabulary -
    -- the data model already rules it (§A3.10): **`0` is the RECORD form of "always
    -- eligible" and `nil` is the STORE form.** So a caller asking for 0 gets `nil`
    -- stored, and the two forms never both exist.
    --
    -- ⚠⚠ WHY THE TRANSLATION IS LOAD-BEARING RATHER THAN TIDY. In Lua `not 0` is
    -- FALSE, so a STORED zero is not stageless to anything that tests the field:
    -- `Outcome` would answer `0 + 1` = **1** (A2.10a's defect, returned by the back
    -- door - the player sent to the start of the route) and `PathOf` would hand out
    -- `"0:n"` as an address for the one node A2.10c says has none. ★ The eight
    -- consumers were measured against NIL; storing 0 quietly un-measures them.
    --
    -- ★ And 0 is unambiguous as a REQUEST because `NextStage` walks from 1 and can
    -- never mint it - so nothing else can arrive here meaning something different.
    local want = tonumber(stage)
    if want == 0 then
        b.stage = nil                              -- the recovery beacon: no stage
    else
        b.stage = want or Routes.NextStage(id)
    end
    b.name  = ""
    r.beacons[#r.beacons + 1] = b
    return b
end

-- ---------------------------------------------------------------------
-- ★★ PLACEMENT - the drag, and why the ORIGIN is kept rather than overwritten
-- ---------------------------------------------------------------------
--
-- Battlewrath, 2026-08-14: *"Keep original. A new field for both. And then the
-- marker spawner for the in-game beacon, and the source projection walk. New else,
-- Original."*
--
-- ★ THE ORIGIN BECOMES A VALUE, NOT A REFERENCE. The coordinates it came from ride
-- on the object itself, so *how we got here* survives export and works on someone
-- else's machine - which is exactly what a back-reference to the run could never do
-- (§61 dropped it; *"someone loading a route against their own data doesn't have the
-- original"*). Provenance without the link.
--
-- One object, two questions, one rule:
--
--     where do I spawn the marker      NEW, else ORIGINAL
--     where did this come from         ORIGINAL, always
--
-- ★ AND OVERWRITING WOULD DESTROY THE NOTE CASE. A note dragged off the route is
-- not a correction - it is placed for its RADIUS, where you will actually walk
-- through it. The original is where the thing happened; the new position is where
-- you want to be reminded. Overwrite it and the only record of which is which is
-- gone, and the source projection walk has nothing to walk to.
--
-- Rhymes with §43 one level up: curation edits the view and never the capture;
-- dragging edits the PLACEMENT and never the origin.

-- ★ `z` IS NOT TOUCHED. §25.2, and it is what lets a beacon sit on top of a wall -
-- compute it and the beacon drops to the floor that wall belongs to, which is
-- precisely not where you need to be standing (§67.1).
--
-- The world pair IS resolved, through §65's calibration, because §60's listen and
-- satisfied radii are DISTANCE checks and a fraction is not metric. His ruling:
-- *"Ideally, the drag would resolve, so a system that projects listen range is from
-- the new position. We always run against a run in view, so we have local
-- calibration."* On the authoring side a run is always loaded (§64), so the samples
-- are always there.
--
-- ★ And when they are not, the pair is left ABSENT rather than guessed. An
-- uncalibrated map is not a reason to invent a world position - it is a reason to
-- say we have not got one.
function Routes.Place(p, atX, atY, mapID, floor)
    if not p or not atX or not atY then return nil end
    p.atX, p.atY = atX, atY
    local C = NS.Calibrate
    local wx, wy
    if C and C.ToWorld then wx, wy = C.ToWorld(mapID, floor, atX, atY) end
    p.atWorldX, p.atWorldY = wx, wy
    return p
end

-- Back to where it came from. The origin was never overwritten, so this is a
-- deletion rather than an inverse - there is nothing to recompute.
function Routes.Unplace(p)
    if not p then return nil end
    p.atX, p.atY, p.atWorldX, p.atWorldY = nil, nil, nil, nil
    return p
end

-- ★ THE ONE RESOLUTION RULE, in one place: NEW else ORIGINAL. Read as a PAIR, so a
-- half-written placement falls back whole instead of mixing one authored axis with
-- one inherited one - which would put the object somewhere neither of them says.
function Routes.PositionOf(p)
    if not p then return nil end
    if p.atX and p.atY then return p.atX, p.atY, true end
    return p.mapX, p.mapY, false
end

-- ---------------------------------------------------------------------
-- ★★★ A11.9b - THE PARK POINT. The supertracker's escapement target.
-- ---------------------------------------------------------------------
--
-- A11.9a: the tracker ALWAYS has a defined target - a node's tabs may set one, and
-- **when none does, the escapement writes the PARK.** So the release stops being a
-- thing somebody must remember at the end of a route: `ROUTER` rules it a REQUIREMENT
-- rather than manners, and the honest weakness of a requirement is that it depends on
-- a call at the right moment. An escapement depends on nobody.
--
-- ⚠⚠ HORIZONTAL, NEVER VERTICAL, and this is measured rather than stylistic.
-- Battlewrath, live 2026-08-20: parked at `x + 1600` the read returned 1600 and then
-- **1583.31 after walking toward it** - it COMPUTES. Directly overhead at 1600,
-- twenty yards of walking moves the reading by **0.125 yd**, indistinguishable from a
-- frozen value. ★ A vertical park is the silent-wrong shape: an instrument that
-- cannot show change looks exactly like a dead one.
--
-- ⚠ SAME mapID, and it comes free: mapID is the CONTINENT, not the room (ROUTER -
-- 1,291 yd of travel never changed it), so 1600 yd out is trivially the same map.
-- Across a map boundary the tracker returns Invalid with distance **0.00, not nil**,
-- and zero satisfies every radius test - so a cross-map park would be a silent
-- false-positive generator rather than an escapement.
--
-- ★ THE CHOICE RULE IS DELIBERATELY DULL. Clearance is the standoff from the nearest
-- node whichever axis is picked - park beyond an extreme and the closest node IS that
-- extreme - so the axis cannot buy more room and nothing is being optimised. The
-- wider spread is chosen only so the park sits off the cluster's mass rather than
-- beside it. **The GUARANTEE is what gets asserted, never the choice.**
local PARK_STANDOFF = 1600      -- yd. Beyond the ~1500 draw range (ROUTER), inside
                                -- the engine's live reading (measured to 3,742 yd).

function Routes.ParkFor(id)
    local r = Routes.Get(id)
    if not r then return nil end

    local lo, hi, ref = nil, nil, nil
    for _, b in ipairs(r.beacons or {}) do
        local nodes = { b }
        for _, c in ipairs(b.children or {}) do nodes[#nodes + 1] = c end
        for _, n in ipairs(nodes) do
            local x, y = Routes.WorldOf(n)
            if x and y then
                lo = lo or { x = x, y = y }
                hi = hi or { x = x, y = y }
                if x < lo.x then lo.x = x end
                if y < lo.y then lo.y = y end
                if x > hi.x then hi.x = x end
                if y > hi.y then hi.y = y end
                ref = ref or n
            end
        end
    end
    -- ⚠ REFUSE RATHER THAN INVENT. A route with nothing placed has no node set to
    -- stand off from, and a park computed from nothing is a coordinate we made up -
    -- the same law as AddBeacon refusing a node with no mapX.
    if not ref then return nil end

    local x, y
    if (hi.x - lo.x) >= (hi.y - lo.y) then
        x, y = hi.x + PARK_STANDOFF, lo.y + (hi.y - lo.y) / 2
    else
        x, y = lo.x + (hi.x - lo.x) / 2, hi.y + PARK_STANDOFF
    end
    -- ★ z comes from a REAL node, never computed: the park is horizontal, so it sits
    -- in the node set's own plane rather than at an invented height.
    return x, y, ref.z, ref.mapID
end

-- ★ WHAT THE PARK GUARANTEES, as a function so a caller can ASSERT it rather than
-- trust it. ⚠ A11.9d makes the parked reference a WITNESS - a continuous cross-check
-- that our arithmetic still agrees with the engine - and a witness standing near a
-- node would answer a question nobody asked.
function Routes.ParkClearance(id)
    local px, py = Routes.ParkFor(id)
    if not px then return nil end
    local worst
    for _, b in ipairs((Routes.Get(id) or {}).beacons or {}) do
        local nodes = { b }
        for _, c in ipairs(b.children or {}) do nodes[#nodes + 1] = c end
        for _, n in ipairs(nodes) do
            local x, y = Routes.WorldOf(n)
            if x and y then
                local dx, dy = px - x, py - y
                local d = math.sqrt(dx * dx + dy * dy)
                if not worst or d < worst then worst = d end
            end
        end
    end
    return worst
end

function Routes.WorldOf(p)
    if not p then return nil end
    if p.atX and p.atY then return p.atWorldX, p.atWorldY end
    return p.x, p.y
end

-- ★ ONE NAME SETTER FOR BOTH OBJECTS. A beacon carries `name`, a personal note
-- carries `text` - different fields because they answer different questions (what
-- this beacon IS versus what you wrote to yourself) - but naming is one gesture and
-- the pane should not have to know which it is holding.
function Routes.SetName(p, name)
    if not p or type(name) ~= "string" then return nil end
    name = name:match("^%s*(.-)%s*$")
    if p.kind == "note" then p.text = name else p.name = name end
    return name
end

function Routes.NameOf(p)
    if not p then return nil end
    return (p.kind == "note") and p.text or p.name
end

-- Deleted BY IDENTITY, not by index: a note plane has no stage numbers, and an
-- index would be wrong the moment anything else removed one first.
function Routes.DeleteNote(mapID, p)
    local plane = Routes.GetNotes(mapID)
    if not plane or not p then return nil end
    for i, q in ipairs(plane.notes) do
        if q == p then return table.remove(plane.notes, i) end
    end
end

-- ★★★ BY ID, NOT BY STAGE (§227). This matched on `b.stage` until the address sheets
-- were run against it, and `routes.lua` DELIBERATELY PERMITS DUPLICATE STAGES - so two
-- beacons at stage 4 meant deleting the second removed the FIRST, and the pane went on
-- showing the one you picked.
--
-- ⚠ Nothing was broken day to day, because stages are normally distinct. It was a
-- fault waiting on a duplicate, which is worse than a live one: the trigger is a state
-- the design invites.
--
-- ★ `stage` is a CHARACTERISTIC - the user can retype it - so it could never have been
-- the handle. An ID that is not unique is not an ID.
function Routes.DeleteBeacon(id, beaconId)
    local r = Routes.Get(id)
    if not r or not beaconId then return nil end
    for i, b in ipairs(r.beacons) do
        if b.id == beaconId then
            table.remove(r.beacons, i)
            return b
        end
    end
end

function Routes.Count(id)
    local r = Routes.Get(id)
    return r and #r.beacons or 0
end

-- ---------------------------------------------------------------------
-- ★★★ §83: CHILDREN - the theatre gets its contents (Battlewrath, 2026-08-15)
-- ---------------------------------------------------------------------
--
-- §78 modelled it and nothing was built: *"I pick a location, but really I'm
-- interested in the theatre space... Then I inspect each data sample for what
-- children I need and where."* The anchor is a NAME FOR A PLACE; the interesting
-- things happen inside it.
--
-- ★★★ RULING: a child carries NO STAGE. The anchor holds the stage, and ANY CHILD
--   WITH THE STAGE-COMPLETE FLAG SATISFIES IT - so children share the anchor's slot
--   rather than having slots of their own. His: *"it is a check for the beacon, that
--   one of its children become satisfied, then the stage is complete."*
--
-- ★ THE MECHANIC IS NAMED, THE STATEMENT DID NOT MOVE (§84). §83 said "any child"
--   because children had no roles yet; once they do, the flagged ones are the
--   satisfier set. His: *"their in spirit the same statement, just the mechanic
--   named."* ⚠ Which is also why the SUBSET framing below still holds - conditional
--   arrived early and mild rather than as the rebuild it was priced as.
--
-- ★★ AND THAT COMPOSES RATHER THAN BRANCHING. The satisfier set is the children,
-- or the anchor itself when it has none - so a childless beacon behaves exactly as
-- it does today with no code path of its own. Same move as §79, where a checkpoint
-- turned out to be a beacon whose outcome you typed rather than a second mechanism.
--
-- ★★ CONDITIONAL IS A LATER SUBSET OF THE SAME SET, not a rebuild. "Which children
-- must flag" narrows it; ANY is the size-one case. His: *"that's a need we don't
-- have yet."* Nothing here forecloses it.
--
-- ⚠ VALUES ONLY, AND THAT IS THE DRIVER SPLIT SPEAKING. He ruled the driver must
-- be installable WITHOUT the editor, reading a flattened list that is *"a product
-- of the auditor, not needing to know how it is all coded in construction"*. A
-- child that held a reference - to its parent, to a sibling, to anything the editor
-- knows how to resolve - could not survive that flattening. So: position, name,
-- and nothing that points.
--
-- ★ Ownership is not a reference. Children hang off the beacon because they ARE the
-- beacon's contents; no child names another child, and no child is named by one.
-- That is his dumb-system ruling holding inside a group as well as between them.
-- ---------------------------------------------------------------------

-- Every child of a beacon, never nil - a caller should not have to ask whether the
-- list exists before counting it.
-- ---------------------------------------------------------------------
-- ★★★ THE CHILD ORDINAL (A2, §312) - an ADDRESS, and an OPTIONAL gate
-- ---------------------------------------------------------------------
--
-- ★★ WHAT IT IS FOR, and the use case is the whole justification (Battlewrath,
-- 2026-08-18): *"A jump to jump to jump. Where multiple R and H might mesh
-- together."* Three platforms in a chain, each with a radius and a height band.
-- Stacked or close, those volumes OVERLAP - falling toward 3 you are inside 1's -
-- and the 2.5 yd band cannot separate them, because the platforms genuinely ARE
-- within a band of each other.
--
-- ⚠⚠ SO THIS IS THE CASE THE FLIGHT LIST DOES NOT COVER. The model's rule is *"the
-- author expresses sequence as DISTANCE, and we never need an execution-order
-- rule"* - true right up until distance stops discriminating. The ordinal is what
-- an author reaches for when geometry has run out, which is exactly why it is an
-- OFFER and never a default.
--
-- ★★★ THE GATE, RULED (Battlewrath, §311): *"The child ordinal (Not stage) gates
-- children who are IN a ordinal, to their ordinal. But children who are NOT in the
-- ordinal are still listened to."*
--
--     child WITH an ordinal      gated - waits its turn
--     child WITHOUT one          always live while its beacon is current
--
-- ★ Which leaves ENTER-FROM-ANY intact (see A2.6's headstone below): the
-- un-ordinaled children stay live, so you can still enter at any state. Opting in
-- to an ordinal is the author accepting sequence where they need it. Two kinds -
-- exactly the two `driver_programmatic_model.md` §1b already lists:
--     Child · NON-ORDINAL   satellite / funnel sensor - ANY ORDER
--     Child · ORDINAL       a chain step - previous satisfied -> this one listens
--
-- ⚠ IT IS NOT A STAGE (model: "A CHILD HAS NO STAGE, BECAUSE IT HAS A PARENT").
-- A stage would be a COPY of the parent's. This is the child's own position within
-- ONE beacon, and it means nothing outside it.

-- Sparse and OPTIONAL. `nil` takes the child OUT of the line - a satellite - and
-- that is a legitimate authoring state, not an unset field waiting to be filled.
-- Fractions are ordinary (3.1 between 3 and 4), which is what makes insertion cost
-- no renumbering.
-- ★★★ `0` IS THE OPT-OUT, AND `nil` IS WHAT IS STORED (Battlewrath, 2026-08-21:
-- *"with 0 being the opt out"*).
--
-- ★ The data model already rules it one tier up (§A3.10): **`0` is the RECORD form of
-- "always eligible" and `nil` is the STORE form** - a caller asking for 0 gets `nil`
-- stored, and the two forms never both exist. `AddBeacon` has done this for STAGES since
-- S7 (§395); the child door never did it for ORDINALS.
--
-- ⚠⚠ AND A STORED ZERO IS NOT HARMLESS - `AddBeacon`'s own note says why, and it is a
-- LUA fact rather than a style one: **`0` is TRUE in Lua**, so every `if child.ordinal`
-- treats a stored zero as *"has an ordinal"*. The node would read as a POSITION to any
-- test written the obvious way while behaving as a zero node at build. Two forms of one
-- fact, disagreeing.
--
-- ⚠ `""` STAYS an opt-out beside 0, because the pane's edit box hands back an empty
-- string when the author clears it, and that is the same gesture.
function Routes.SetChildOrdinal(b, child, n)
    if not child then return nil end
    if n == nil or n == "" then
        child.ordinal = nil                      -- out of the line, on purpose
        return nil
    end
    local v = tonumber(n)
    if not v then return child.ordinal end       -- unparseable: keep what was there
    if v == 0 then
        child.ordinal = nil                      -- the OPT-OUT, stored as absence
        return nil
    end
    child.ordinal = v
    return child.ordinal
end

function Routes.OrdinalOf(child) return child and child.ordinal or nil end

-- ★★ THE ORDER IS A VIEW, NOT A STORED SORT - the same call this file already makes
-- for parentage (*"COMPUTED, never stored"*). `b.children` keeps INSERTION order, so
-- the record of what was minted when survives, and the ordinal is a lens over it.
-- ⚠ A stored sort would also make every ordinal edit a write to the child LIST, and
-- a list rewritten on an attribute edit is where ordering bugs live.
--
-- ★ Satellites sort AFTER the line, in insertion order. They are outside the
-- sequence by definition, so putting them first would read as ordinal 0.
-- ⚠ STABLE by decoration: `table.sort` is not stable in Lua, and A2.3 permits two
-- children on one ordinal - without the index tiebreak they would swap between calls
-- and the pane would appear to shuffle on its own.
function Routes.ChildrenOf(b)
    if not b or not b.children then return {} end
    local out = {}
    for i, c in ipairs(b.children) do out[i] = { c = c, i = i } end
    table.sort(out, function(x, y)
        local a, z = x.c.ordinal, y.c.ordinal
        if a and z then
            if a ~= z then return a < z end
        elseif a or z then
            return a ~= nil                      -- the line first, satellites after
        end
        return x.i < y.i                         -- insertion order breaks every tie
    end)
    for i, e in ipairs(out) do out[i] = e.c end
    return out
end

-- ⚠ THE STORED ORDER, when you need the record rather than the view. `DeleteChild`
-- and `mint` work on `b.children` directly and must keep doing so.
function Routes.ChildrenAsMinted(b)
    if not b then return {} end
    return b.children or {}
end

-- How many OTHER children already sit on this ordinal. ★ The same shape as
-- `RoleMatches` and `StageMatches`: it REPORTS a collision and never prevents one
-- (§90, S4 tell-and-trust). Two children on one ordinal is authorable - they simply
-- gate together.
function Routes.OrdinalMatches(b, n, except)
    local v = tonumber(n)
    if not v then return 0 end
    local hits = 0
    for _, c in ipairs(Routes.ChildrenAsMinted(b)) do
        if c ~= except and c.ordinal == v then hits = hits + 1 end
    end
    return hits
end
-- ---------------------------------------------------------------------
-- ★★ A2.11 (§394) - THE ORDINAL MINT AND GAP. The stage side has had
-- `NextStage` and `Gaps` since §56; the child side had NEITHER, so A10.3e's
-- ordinal picker could not be built. `OrdinalMatches` above counts collisions
-- and mints nothing.
--
-- ★ SCOPED TO THE PARENT (A2.11a), like `OrdinalMatches` and unlike the stage
-- pair. Ordinals are per-beacon: two beacons legitimately both have a child at
-- ordinal 1, and a mint that walked the route would collide across them.
-- ---------------------------------------------------------------------

-- The lowest free WHOLE ordinal among this beacon's children (A2.11b).
--
-- ⚠ A child with NO ordinal is SKIPPED, never counted as 0. `child.ordinal = nil`
-- is "out of the line, on purpose" (:566) - the update type, listened to at any
-- time - so it is not in the numbering and must not consume a number.
function Routes.NextOrdinal(b)
    if not b then return 1 end
    local used = {}
    for _, c in ipairs(Routes.ChildrenAsMinted(b)) do
        if c.ordinal ~= nil then used[c.ordinal] = true end
    end
    local n = 1
    while used[n] do n = n + 1 end
    return n
end

-- ★★★ A2.11c - THE GAP FUNCTION IS NOT A MIRROR OF `Gaps`, and this is the whole
-- reason it is a separate function rather than a second caller.
--
-- Beacon stages are WHOLE ONLY (data model §A3.9), so an integer walk is complete
-- for them. **Child ordinals are the author's choice** - `1.1 · 1.2` is legal on
-- the same authority - so "what is a gap" has to be SAID:
--
--     ordinals 1 · 2 · 4     ->  a gap at 3     a missing WHOLE number
--     ordinals 1 · 1.5 · 2   ->  NO gap         1.5 is INSERTION, not a hole
--
-- ⚠ So a fraction never CREATES a gap and never FILLS one. It does not raise the
-- ceiling either: with 1 · 1.5 the highest whole in use is 1, and there is nothing
-- between 1 and itself. ★ That follows from what the offer is FOR - Battlewrath,
-- 2026-08-19: *"then the gaps stand out"* - which is legibility. A decimal sitting
-- between two wholes is not a hole in anything a reader is looking for.
function Routes.OrdinalGaps(b, limit)
    if not b then return {} end
    local used, top = {}, 0
    for _, c in ipairs(Routes.ChildrenAsMinted(b)) do
        local o = c.ordinal
        if o ~= nil then
            used[o] = true
            -- ⚠ ONLY A WHOLE ORDINAL RAISES THE CEILING. `Gaps` floors the top
            -- instead; flooring 1.5 to 1 would be the same answer here by accident
            -- and the WRONG one the moment a route ran 1 · 2.5 - it would report a
            -- gap at 2, which no author left.
            if o == math.floor(o) and o > top then top = o end
        end
    end
    local out = {}
    for n = 1, top do
        if not used[n] then
            out[#out + 1] = n
            if limit and #out >= limit then break end
        end
    end
    return out
end

-- ★★ THE ADDRESS - `4.1:3`, beacon stage before the colon, child ordinal after
-- (C10). Returns the child AND how many matched, because uniqueness here is
-- REPORTED, not enforced: two beacons may share a stage (`StageMatches` says so and
-- refuses nothing), so a path can be ambiguous and the caller is told rather than
-- lied to.
function Routes.ChildAt(id, path)
    local r = Routes.Get(id)
    if not r or type(path) ~= "string" then return nil, 0 end
    local sTxt, oTxt = path:match("^%s*([%d%.]+)%s*:%s*([%d%.]+)%s*$")
    local stage, ord = tonumber(sTxt), tonumber(oTxt)
    if not stage or not ord then return nil, 0 end
    local found, hits = nil, 0
    for _, b in ipairs(r.beacons or {}) do
        if b.stage == stage then
            for _, c in ipairs(Routes.ChildrenAsMinted(b)) do
                if c.ordinal == ord then
                    hits = hits + 1
                    found = found or c
                end
            end
        end
    end
    return found, hits
end

-- The other direction. nil when the child is a satellite - it HAS no path, which is
-- different from having one nobody has written yet.
function Routes.PathOf(id, child)
    if not child or child.ordinal == nil then return nil end
    local b = Routes.ParentOf(id, child)
    if not b or not b.stage then return nil end
    return ("%g:%g"):format(b.stage, child.ordinal)
end

-- ★★★ THE GATE. Stateless by construction: `satisfied` is a set the CALLER owns,
-- keyed by the child table. This file stores no runtime state and never has - the
-- driver will hold what it has satisfied, and ask this the shape of the question.
--
-- ⚠ WRITTEN AGAINST THE IMMEDIATE PREDECESSOR, which is what the model says
-- literally (*"previous satisfied -> this one listens"*). With the gate in force
-- that is equivalent to "every lower one satisfied", because nothing can satisfy
-- out of order - and stating it as the model does keeps one sentence, not two.
function Routes.ListensNow(b, child, satisfied)
    if not child then return false end
    if child.ordinal == nil then return true end     -- a satellite is always live
    satisfied = satisfied or {}
    local prev = nil
    for _, c in ipairs(Routes.ChildrenAsMinted(b)) do
        if c ~= child and c.ordinal ~= nil and c.ordinal < child.ordinal then
            if prev == nil or c.ordinal > prev.ordinal then prev = c end
        end
    end
    if prev == nil then return true end              -- first in the line
    return satisfied[prev] and true or false
end


function Routes.ChildCount(b)
    return #Routes.ChildrenOf(b)
end

-- ★★★ §91: A CHILD CARRIES AN IMMUTABLE OPAQUE ID, and it is one of the eight
-- standing data laws in `COA_Landmarks/store.lua` rather than a new idea. Table
-- identity works in memory and means NOTHING in a file - so the moment one child
-- points at another, the link needs a name that survives an export.
--
-- ⚠ MONOTONIC PER ROUTE, never reused. Reusing a freed id makes a stale reference
-- resolve to the WRONG child instead of to nothing, which turns a loud break into a
-- silent one. The counter only ever goes up.
local function nextChildId(r)
    r.nextChildId = (r.nextChildId or 0) + 1
    return r.nextChildId
end

-- ★★ ONE MINT, TWO SOURCES. Both spawners land here: the difference is only WHERE
-- the position came from, so there is one place that knows what a child IS.
-- ★★★ THE ORDINAL RATCHETS HERE (Battlewrath, 2026-08-21): *"setting the baseline to
-- ratchet and then select out."*
--
-- ⚠⚠ `Routes.NextOrdinal` EXISTED WITH NO CALLER, so **every child ever placed was a
-- zero node** - measured, and the Analyst put it as *"every node must auto to do nothing,
-- where most nodes are expected to advance"* (RI-49b). ★ It predates the no-outcome
-- landing rather than being caused by it: `NodeDone` already required `step > 0`, so no
-- authored route had ever advanced by step. The landing only made it VISIBLE.
--
-- ★★ RATCHET, THEN SELECT OUT - the default is the common case and the exception is a
-- CHOICE. The architect's own mapping says `start` = ordinal 1 (AL-21), which nothing
-- minted; a placed child is a position in the sequence unless its author says otherwise,
-- and `SetChildOrdinal(b, child, nil)` is how they say so.
--
-- ⚠ IT IS THE ONE DOOR. `AddChildFromNode` and `AddChildHere` both come through here, so
-- there is no placement path that skips the ratchet - the same reason the seed lives at
-- `RowsOf` (*"a door has no before"*).
-- ★★★ A10.3e-R · THE STANDING R IS 5 - THE DEFAULT AND THE FLOOR AT ONCE.
--
-- Battlewrath, 2026-08-21: *"A default 5 yards R is expected. Enforced at the picker. We
-- can have that the standing R."* And 2026-08-22, moving it EARLIER: *"It should be minted
-- with the R5 floor."* ⟶ A node is drivable the moment it exists, rather than at the
-- moment somebody remembers to open a pane.
--
-- ★★ AND THE NUMBER IS ARITHMETIC ALREADY ON RECORD, not a preference:
--
--     R_min = v_ceiling × POLL_MIN / 2 = 100 × 0.1 / 2 = 5
--
-- At R = 5 the diameter is 10 yd and the fastest thing the project calls travel
-- (`TELEPORT_VMAX` 100) covers exactly that in one 0.1 s step. ⚠ Below 5 the poll floor
-- stops guaranteeing a sample lands inside the node. R, the poll floor and the travel
-- ceiling are ONE relationship - move any and the others move.
--
-- ⚠⚠ THE MINT DEFAULTING IT DOES NOT MAKE `Bucket.Build` STOP REFUSING NIL, and
-- A10.3e-R is explicit about why: once the default ships, **a nil radius can only mean
-- pre-default data**, which is exactly what a refusal should say. ★ R is not the BAND -
-- a nil band means *the author did not pick* and resolves to 2.5, because a tolerance has
-- a safe default and **how big a thing is** does not.
Routes.R_FLOOR = 5

-- ★★★ THE CEILING AND THE LADDER (Battlewrath, 2026-08-22): *"For the R limit, maybe
-- 300 yards. in a 5, 15, 25, 50, 100, 150, 300 stepping."*
--
-- ⚠⚠ THE STEPS ARE THE PICKER'S OFFER, NOT A CONSTRAINT ON THE FIELD. R is a distance
-- and the store keeps a number; nothing downstream may assume it is one of seven values.
-- ★ Same shape as everything else here that offers rather than restricts: the stage's
-- ghosted next round number that you may type past, and the ordinal's next-free. The
-- ladder is how you MOVE the value without typing; the FLOOR and the CEILING are the
-- only two things actually enforced.
--
-- ★★ AND IT CLIMBS THE WAY DISTANCE READS, not in equal steps. 5→15 is the difference
-- between a doorway and a room; 150→300 is the difference between two ends of a wing.
-- Equal steps would spend most of the ladder on sizes nobody authors.
--
-- ☐ 300 IS HIS NUMBER AND CARRIES NO DERIVATION - unlike the floor, which is
-- `v_ceiling × POLL_MIN / 2`. It is a judgement about how big a thing a node may be, and
-- it is recorded as one rather than dressed up as arithmetic.
Routes.R_CEILING = 300
Routes.R_STEPS = { 5, 15, 25, 50, 100, 150, 300 }

-- ★ THE LADDER'S ENDS **ARE** THE FLOOR AND THE CEILING - stated here so the three
-- cannot drift into disagreeing. A ladder whose first rung sits under the floor offers a
-- value the setter would silently clamp, which is a control that lies.

-- ⚠ THE STEP ABOVE / BELOW, so a picker does not re-derive the ladder. Returns the
-- CURRENT value at either end rather than nil: a stepper that goes dead at the top is
-- indistinguishable from a broken one.
function Routes.StepR(from, by)
    local cur = tonumber(from) or Routes.R_FLOOR
    local steps = Routes.R_STEPS
    if by > 0 then
        for _, v in ipairs(steps) do if v > cur then return v end end
        return steps[#steps]
    end
    for i = #steps, 1, -1 do if steps[i] < cur then return steps[i] end end
    return steps[1]
end

local function mint(r, b, place)
    if not r or not b or not place or not place.mapX then return nil end
    place.kind = "child"
    place.name = ""
    place.id = nextChildId(r)
    place.ordinal = Routes.NextOrdinal(b)
    -- ★ A10.3e-R's test: *mint a child, touch nothing → its radius is 5 and the route
    -- builds.* ⚠ `Routes.Inherit` carries PLACE and nothing else, deliberately - so the
    -- radius is not inherited from the capture, it is the standing R.
    place.radius = Routes.R_FLOOR
    b.children = b.children or {}
    b.children[#b.children + 1] = place
    return place
end

-- ★ FROM A NODE, exactly as a beacon is minted from one - Routes.Inherit is the one
-- borrow, so a child and a beacon carry the same PLACE fields and the map cannot
-- tell them apart when it draws them.
function Routes.AddChildFromNode(id, b, node)
    local r = Routes.Get(id)
    if not r or not b or not node then return nil end
    return mint(r, b, Routes.Inherit(node))
end

-- ★ FROM THE BEACON ITSELF. It takes the beacon's EFFECTIVE position (new else
-- original, via PositionOf) rather than its origin: if the author dragged the
-- beacon somewhere, that is where they mean.
--
-- ⚠ The child then owns those coordinates as its ORIGIN. Moving the beacon
-- afterwards does not move the child, and it must not - a child is a place in the
-- theatre, not an offset from the anchor. `new else original` only ever resolves
-- against a point's OWN pair.
function Routes.AddChildHere(id, b)
    local r = Routes.Get(id)
    if not r or not b then return nil end
    local mx, my = Routes.PositionOf(b)
    if not mx then return nil end
    local wx, wy = Routes.WorldOf(b)
    return mint(r, b, { mapX = mx, mapY = my, x = wx, y = wy, z = b.z,
                        mapC = b.mapC, mapZ = b.mapZ, mapID = b.mapID, floor = b.floor })
end

-- ⚠ BY IDENTITY, not by index. An index is stale the moment anything else is
-- deleted, and the pane holds the child itself rather than a position in a list.
function Routes.DeleteChild(b, child)
    if not b or not child or not b.children then return nil end
    for i, c in ipairs(b.children) do
        if c == child then
            table.remove(b.children, i)
            if #b.children == 0 then b.children = nil end   -- by-exception: no empty lists stored
            return c
        end
    end
end

-- Which beacon owns this child. ⚠ COMPUTED, never stored - a stored parent link is
-- the reference the driver split forbids, and it would need maintaining on every
-- delete. The editor can afford the walk; the driver never asks.
function Routes.ParentOf(id, child)
    local r = Routes.Get(id)
    if not r or not child then return nil end
    for _, b in ipairs(r.beacons) do
        for _, c in ipairs(b.children or {}) do
            if c == child then return b end
        end
    end
end

-- ★★★ A8.1 (§329) - THE FLAT CHECK AS A FUNCTION, NOT A FIELD. The model asks for
-- this by name: *"Take the flat check as a FUNCTION, not a field: `Routes.StageOf(node)`
-- - its own stage if a beacon, its parent's if a child. One predicate, computed, never
-- stale."*
--
-- ⚠⚠ AND IT IS WHY A CHILD HAS NO STAGE. A child's stage would be a COPY of its
-- parent's, and then every restage has to remember its children or they go stale in
-- silence. ★ The hop costs nothing here: the editor can afford the walk, and the driver
-- never asks - the same call this file already makes for parentage.
--
-- ★★ IT IS NOT "THE CHILD'S STAGE" (Battlewrath, §330). It is WHICH STAGE THE BEACON
-- I BELONG TO IS ON. *"Their relationship is ID, not stage. And the child stage is
-- unique by the parent ID."* A child is bound to its parent by IDENTITY (`BID:CID`),
-- and its own position is its ordinal, unique within that BID. ⚠ So restaging a parent
-- MOVES NOTHING about the child - the answer here changes because the PARENT moved,
-- and the lookup is live rather than a value somebody had to remember to update.
--
-- ⚠ A CHILD'S OWN `stage` FIELD IS IGNORED IF ONE EXISTS. That is deliberate: a stale
-- copy is exactly the thing this function is here to make unreachable, so reading it
-- would defeat the point of computing. `setStage` is a different field - what a `set`
-- role ASSIGNS - and is untouched.
function Routes.StageOf(id, node)
    if not node then return nil end
    if node.kind == "beacon" then return node.stage end
    local b = Routes.ParentOf(id, node)
    return b and b.stage or nil
end

-- ---------------------------------------------------------------------
-- ★★★ §86: WHY A CHILD POINTS AT ANOTHER - a rule is not a capability
-- ---------------------------------------------------------------------
--
-- Battlewrath, 2026-08-15, on what the point-to is FOR:
--
--     "The main reason for the point to is so one space doesn't need to be several
--      beacons because we made a rule, not a capability. Which is what put a lot of
--      tension on beacon v1."
--
-- ★★★ THE LAW: WHEN A RULE FORCES YOU TO FRAGMENT A THING, THE RULE IS A MISSING
-- CAPABILITY. If one theatre with three waypoints has to be authored as three
-- beacons, the author is encoding OUR limitation into THEIR data - and the route
-- then says something about the tool rather than about the dungeon.
--
-- ⚠ That was beacon v1's tension, and it is worth naming because it does not
-- announce itself: the model looked like it worked, and the cost showed up as
-- authoring friction that read like the author's problem.
--
-- ⚠⚠ THE SHAPE THIS ARGUED FOR IS RETIRED (A2.6). It was: a child carries an optional
-- `goTo`; reaching it moves the waypoint THERE; a target that no longer resolves simply
-- stops redirecting. ★ That last clause is the tell - "a target that no longer
-- resolves" is a STALE POINTER described as an authoring state, and three checks
-- existed to find them. Nothing points outwards now; order is the ordinal alone.
--
-- ★★ THE LAW ABOVE STANDS AND IS WHY THIS IS NOT DELETED. "When a rule forces you to
-- fragment a thing, the rule is a missing capability" outlives the mechanism it was
-- argued for: one theatre with three waypoints is still one beacon with three STEPS,
-- and the author still never encodes our limitation into their data. The capability
-- survived; only the way of expressing it changed.
--
-- ★★★ ENTER-FROM-ANY IS THE DESIGN. An ordinal chain would need to know which link
-- is ACTIVE - runtime state, and it assumes you walked in from the front. This needs
-- none: whatever range you are standing in says where to go next, so entering
-- anywhere works. His: *"only if you can enter at any state."*
--
-- ★ THE ORDER IS DERIVED, NEVER TYPED. His: *"it's a custody argument of who points
-- at who. One starts the pointing. One points at no one. And that forms the chain
-- and order."* ⚠ Walking custody yields a GRAPH, not a line - several heads are
-- legitimate (each is an entry point) and two children may converge on one target.
-- A display that draws 1 -> 2 -> 3 must not treat everything outside it as broken.
--
-- ⚠ THE IDENTITY COUPLING IS SAFE HERE AND WAS NOT AT THE BEACON LEVEL. There, a
-- missing target BREAKS THE SEQUENCE and needs fixing in two places. Here a missing
-- target degrades to "no redirect", which is already a defined state. The reference
-- is SOFT, and that is the whole difference.
--
-- ★★ AUTHOR WITH AN ID, FLATTEN TO COORDINATES. The editor keeps a live link so
-- ⚠ A2.6: no redirect names anything now, so the auditor has nothing to resolve.
-- The paragraph below described `goTo`
-- into a position at export, and the driver never learns references exist. ⚠ Which
-- is the first evidence the flatten is a TRANSFORMATION, not a serialisation.
-- ---------------------------------------------------------------------

-- ---------------------------------------------------------------------
-- ★★★ §85: THE CHILD'S PROPERTIES - two axes, competition inside each
-- ---------------------------------------------------------------------
--
-- §84 scoped it as a tick tree: *"a logic tree tick box selection. Where multiple
-- flags can be true, unless they compete."*
--
--   DETECT   when this fires      competes with its own type, radius and band
--   ACTION   what happens then    competes with its own content
--
-- ★★ A CHILD CARRIES BOTH, which is what makes the useful composition free: the
-- child that completes the stage and the child that clears the note can be THE SAME
-- CHILD, with no coordination between the axes.
--
-- ★★★ AND THE COMPETITION IS ENCODED, NEVER REMEMBERED. Setting a role clears that
-- role from the siblings; setting the waypoint clears theirs. Two stage-completes on
-- one beacon is not discouraged, it is UNREPRESENTABLE - the same argument as the
-- map's single arm, adapted to a group that has to flatten to values.
--
-- ⚠ WHY NOT A SLOT ON THE BEACON. `b.complete = <child>` is a REFERENCE, and §83
-- keeps children free of those so the flattened list can carry them as values. An
-- index rots on the first delete. A flag on the child plus clear-the-siblings is the
-- only form that survives both.
-- ---------------------------------------------------------------------

-- ★ THE ROLES. `complete` is the load-bearing one - §84 renamed it from `end`
-- because start/end read as two halves of one span and invited both to matter.
--   start     annotates arrival at the stage
--   update    annotates progress within it
--   complete  SATISFIES the anchor: index = max(index, outcome)
--   set       ASSIGNS: index = N, no max. The only thing that can move a player
--             BACKWARDS, which is why it is authored rather than inferred.
Routes.ROLES = { "start", "update", "complete", "set" }
Routes.SHAPES = { "radius", "wire" }
-- ⚠ §91: `waypoint` became `supertrack` because the name was the model. And `note` is
-- OUT for now, on his call: with ids, a note is likely a CONSUMER several children
-- reference rather than a string each one owns - *"you update one note. On route
-- export, the same note or a ref lookup is set into both."* Authoring it as a
-- per-child field today would be data to migrate the moment that lands.
Routes.ACTIONS = { "supertrack" }

local function has(list, v)
    for _, x in ipairs(list) do if x == v then return true end end
    return false
end

-- ★★★ §90: ONLY `set` IS EXCLUSIVE, AND THIS IS A RULING THAT CAME BACK DOWN.
--
-- §85 cleared the role from every sibling on the reasoning that *"there is one
-- super-tracker slot, so two claimants have no answer"*. ⚠ That was never true of
-- `complete`: §84 settled the semantics as ANY CHILD WITH THE FLAG SATISFIES, so two
-- of them is not an ambiguity, it is the set having two members. Whichever fires
-- first satisfies, and the outcome belongs to the BEACON - so both produce the same
-- index. The rule was preventing nothing and removing an authoring option.
--
-- ⚠⚠ AND THE WAY IT REMOVED IT WAS THE WORSE HALF: it SILENTLY CLEARED a sibling's
-- flag. §81 had already ruled on this exact shape one level up - a duplicate stage is
-- ALLOWED, shown with a match count, because *"refusing it would be grading the
-- author's work. The consequence is real and theirs."* I built the opposite here
-- without noticing it contradicted that.
--
-- ★★★ `set` STAYS EXCLUSIVE, and for a reason the others do not have: two
-- ASSIGNMENTS firing in one theatre have NO DEFINED RESULT, not merely an unclear
-- one. That is genuine ambiguity rather than a tolerated duplicate.
--
-- ★ HOW IT CAME DOWN, because the process is the point (Battlewrath, 2026-08-15):
-- *"We run on a idea. We get enough surface to describe it. Then we implement in
-- better form. Then we go in a circle until the stable thing comes out. And then it
-- is from those findings we can make more certain claims."* Certainty is an OUTPUT of
-- ---------------------------------------------------------------------
-- ★★★ THE SENSE (G10, §321) — stage one of `sense → when true → next`
-- ---------------------------------------------------------------------
--
-- ★★ IT IS NOT A NEW AXIS. `driver_programmatic_model.md` §3 carries `sense:` on every
-- default row - *"childless beacon — sense: reach here"*, *"boss child — sense: boss
-- engaged/killed"* - and §5 states the gap outright: *"G2 reach on a childless beacon
-- (THE DEFAULT SENSE HAS NO FIELD)"*. The model named this axis and knew it was
-- unstored. G10 gives it a field, and only for the case that departs from the default.
--
-- ⚠ SO THE DEFAULT STORES NOTHING, exactly as `outcome` does (§79): *"a route full of
-- ordinary beacons carries no field at all and nothing has to be migrated."* A node
-- with no `sense` means REACH HERE, which is the node being a node - its position is
-- intrinsic (model §1b makes it the listening filter) and its reach is configuration.
--
-- ★ `reachHere` is therefore NOT in SENSES. SENSES is the SETTABLE list; the default is
-- what you get by setting nothing. Offering it as a value would let an author store a
-- field whose only meaning is "I did not choose", which is the one thing §79 avoided.
-- ⚠⚠ EMPTY, AND THE EMPTINESS IS THE RULING (RI-15/RI-17). This is the SETTABLE list -
-- the senses an author can pick for a node - and boss LEFT it: *"boss is NOT a sense.
-- While (duration) is the arming to listen to CLEU, and boss is the CLEU."* It is now
-- the ACTION word of a WHAT I DO row.
--
-- ★ And nothing replaced it. `falling` / `in combat` are NOT senses either - Battlewrath:
-- *"those would live in the wider logic that needs something that gates on combat to be
-- a condition"* - they are GATES, and what a function is CONSTRUCTED OF, never a term
-- the author picks. So the list stays empty until a state sense actually lands.
--
-- ⚠ Empty is not broken. `reachHere` is the DEFAULT and was never in here (§79: the
-- default stores nothing), so a node's sense still resolves; there is simply nothing
-- else to choose yet.
Routes.SENSES = {}
Routes.SENSE_DEFAULT = "reachHere"

-- ⚠ The list is DECLARED and CHECKED, not CLOSED (§305). A setter refusing an unknown
-- value guards a typo at a moment in time; the model's box is what the program can
-- OFFER and it grows - STATE senses (in combat · falling/landed · alive/dead · mounted)
-- and `scene entered` are in it, unbuilt. Adding one is a row here, never a refactor.
function Routes.SetChildSense(b, child, sense)
    if not child then return nil end
    if sense == nil or sense == Routes.SENSE_DEFAULT then
        child.sense = nil                    -- back to the default; nothing stored
        child.boss = nil                     -- ⚠ and the name goes with it - see below
        return nil
    end
    if not has(Routes.SENSES, sense) then return child.sense end
    child.sense = sense
    return child.sense
end

-- R6's pair (proposition §13b): the RAW reading and the RESOLVED one are different
-- questions from different callers - *was this authored* and *what does this node do*.
function Routes.SenseOf(child) return child and child.sense or nil end

function Routes.Sense(x)
    if not x then return nil end
    return x.sense or Routes.SENSE_DEFAULT
end

-- ★★ THE NAME IS PICKED, NEVER TYPED (A3.1). The offer comes from the run's own record
-- and the setter refuses anything not in it, so "picked" is a property of the data path
-- rather than of the pane being careful.
--
-- ⚠ AND IT IS PICKED AT AUTHORING, from the LOADED RUN - not looked up later. §61
-- DROPPED the route→run back-reference, so a route owes its origin nothing and cannot
-- ask it anything afterwards. The name is copied in at the moment of choosing, which is
-- the same law as PLACE carrying and EVENT not.
-- ---------------------------------------------------------------------
-- ★★★ THE ROW - ONE DECLARATION, `<sense>:<action>:<arg>` (RI-17)
-- ---------------------------------------------------------------------
--
-- Battlewrath: *"The instructions that export do not carry each program instruction. The
-- driver has that built in. It just needs to be told `While:Boss:Bossname`."*
--
-- ★★ So a WHAT I DO row is not a record with a condition field and an action field and a
-- tail. It is ONE declaration, stored whole, exported whole, read whole. The ACTION WORD
-- names a function the driver already implements; the driver holds every step of HOW.
-- The author states the OUTCOME - *"they don't build how that is performed."*
--
-- ⚠ WHICH IS WHY THERE IS NO CONDITION FIELD. `boss` carries its own condition (the
-- kill) and its own completion (set stage to this beacon's next, absolute - recovery).
-- A separate condition field would be us re-describing the inside of a function the
-- driver owns, and it is exactly what RI-17 struck.
--
-- ★ THE SENSE-WORD IS PER ROW, the node's SENSE is per node. The node answers *where and
-- what am I doing there*; the row answers *at which edge of that*. Three words:
Routes.SENSE_WORDS = { "whenOn", "seen", "whenOff" }

-- ⚠ AN OPEN LIST, NAMED AS THEY LAND (model §2). Adding one is a line here plus the
-- driver's implementation - which is the whole point of the grammar: the route names a
-- function, so a new function costs the route nothing.
-- ⚠⚠ `set` AND `ratchet` ARE NOT HERE, and I had them here until I checked the basis.
-- DRIVER_BASIS (NEXT, 2026-08-18): *"tabs have no sequence, all fire on sense, so a `set
-- stage` TAB fires on arrival mid-fight. A stage change is NOT a tab - it is the node's
-- characteristic NEXT... `set`/`ratchet` are not action words."*
--
-- ★ THE LOGIC HOLE IS THE REASON, not tidiness: rows all fire on the sense, so a stage
-- change expressed as a row fires the moment the player arrives - mid-fight, before the
-- kill it was meant to follow. Making it the node's characteristic, read when ALL tabs
-- are good, is what puts it after the thing it depends on.
-- ★★★ `supertrack` LEFT THIS LIST (AL-19, Battlewrath's reading). *"The super tracker
-- is what gets the player TO the sense site. So if it is an option, it lives in the
-- CHARACTER, not behaviour."*
--
-- ⚠⚠ AND THE TIMING IS WHY IT COULD NEVER HAVE WORKED HERE: a behaviour row fires on its
-- SENSE, and the only sense that fits a waypoint is `whenOn` - arrival - so the row would
-- have pointed the arrow at the node the reader was ALREADY STANDING IN. ★ A2.6 is what
-- made it so: while it could point OUTWARDS it was a real choice about a TARGET; once it
-- could name only itself, it became a property OF THE NODE. The field did not move, the
-- mechanism under it did, and the field was never re-seated.
--
-- ★ THE LIST SHRANK, which is the safe direction for a security boundary (§464): one
-- fewer verb a travelling file may name. It is an OPEN list - it may grow again - but
-- every entry has to be something that HAPPENS WHEN THE READER IS HERE.
Routes.ROW_ACTIONS = { "boss", "note", "say" }

-- ★★★ `Next(Type, arg)` — THE FIELD THE STORE OWED (AL-21, closing RI-49).
--
-- ⚠⚠ `contract.lua:83` DECLARED `nextType`/`nextArg` ALL ALONG and the store never had
-- them - *"the declaration was ahead of the store"*, which is the third time this week a
-- declared thing had no consumer (`ROW_ARG`, `ROW_ARG_RULE`, and now this).
--
-- ★ ONE FIELD, TWO SLOTS (model row 12): the arg is present ONLY for `set`.
--     step    the next positive ordinal
--     stage   THE NEXT STAGE PRESENT in the route - never +1 (AL-9)
--     set     stage N, which is what makes §4b's recovery escapement authorable
--
-- ⚠⚠ AND ABSENT IS AN OUTCOME, NOT A BLANK (§479's landing, taken by AL-21's addendum).
-- Which outcome is DERIVED from position: an ordinalled node's absent Next is `step`; a
-- ZERO node's is **nothing follows**. ★ That is why there is no fourth word here and no
-- degenerate `set` - a `set` with no N is half-stated, and the guard already refuses that
-- shape everywhere else.
Routes.NEXT_TYPES = { "step", "stage", "set" }

-- ★★★ THE LATCH (AL-23, Battlewrath) — TWO OF THEM, EACH THE AUTHOR'S CHOICE.
--
-- > *"It's a latch. So it has to complete before it is released and can be re-armed. And a
-- > sensible follow-on is each action needs its own latch. **A boss room isn't one chance to
-- > kill it or our system breaks.** At the same time we don't want to spam LoS every time you
-- > run over it."*
--
--     PER TAB (the row)        `once`  fires, latches on completion, SPENT until the node re-arms
--                              `every` released when the SENSE DROPS, so it re-fires on the next
--                                      qualification - never on every poll
--     PER STEP/STAGE (the node) `once`  LEAVES the offered list on completion
--                              `every` MAINTAINED in the list, re-stating on re-qualification
--
-- ★★ ONE MECHANISM ANSWERS BOTH OF HIS CASES: the latch-while-held stops the LoS spam, and
-- the release-on-drop gives the boss its second chance - **a row latches on COMPLETION, and a
-- boss row never latches on a wipe**, so it re-arms on re-entry without anyone writing a
-- wipe-detector.
--
-- ⚠ "EVERY TIME" MEANS EVERY **QUALIFICATION**, NEVER EVERY POLL. The latch is what makes
-- that true; without it "every" would mean "on every sample the sense holds".
--
-- ⚠ THE DEFAULT STORES NOTHING (§79): absent is `once`, so a route carries a trigger only
-- where the author chose the exception. That is his standing shape - *"an exception by
-- selection"* - and it keeps an unauthored node's record empty.
Routes.TRIGGERS = { "once", "every" }

-- ★★★ THE OFFERED DEFAULT PER ACTION WORD (AL-35, Battlewrath 2026-08-22).
--
-- ⚠ BOTH LATCHES ARE **AUTHORED**, and the architect's derived read was STRUCK. His:
-- *"I'd lean in authored. They have different use cases … Why not derive from boss action?
-- Questionable. But that hides the setters, which is not programmatic. We can flip and
-- offer, WeakAuras-like."*
--
-- ⟶ So this is an **OFFER, never a derivation**: the picker pre-selects what it names and
-- the author flips it in one click. The setter stays in view, which is the whole ruling.
--
--     boss   every    ★ his: *"you can safely wipe and retry"* - a boss room is not one
--                     chance, and Once is unwanted there (AL-23's own reason for `every`)
--     say    once     ★ his: no running across making the character speak; in a wipe it is
--                     the last instruction the group carried, fresh in memory
--     note   once     ⚠ THE BENCH PROPOSED, and AL-35 says so - *"note → the bench
--                     proposes, the author flips."* ★ The two errors are not equal: a wrong
--                     `once` costs a repeat nobody saw, a wrong `every` is the LoS spam the
--                     latch was ruled to prevent.
--
--                     ❌ AND THE BENCH'S OWN COUNTER-ARGUMENT WAS STRUCK (Battlewrath,
--                     2026-08-23). I had written that *"a note on a boss pull arguably
--                     wants to reappear on a retry"*. His: *"One action tab has one
--                     control. WA trigger - type. **So a note doesn't know it's on a node
--                     with a boss.**"* ⟶ A tab is scoped to ITSELF, the way a WeakAuras
--                     trigger is - it cannot see its siblings, so there is no such thing as
--                     a note that is *on a boss pull*. The argument was about a node; the
--                     control belongs to a tab.

-- ★★★ AND THE OFFER IS **PER SELECTION** - fixed to the word you pick, never varied by
-- what else is on the node (Battlewrath, 2026-08-23):
--
--     *"making a system that keeps changing makes a system users react to rather than
--     know. So I'd have it per selection."*
--
-- ⚠ That forbids the whole family of clever defaults: no *"boss present, so the note
-- repeats"*, no *"first tab differs from the rest"*, no offer that reads the node. **Pick
-- `say` and you get `once`, every time, on every node, forever.**
--
-- ★★ IT IS THE #1 DESIGN RULE FROM THE OTHER END. `plays-by-flattening-decisions` says
-- reduce decision load and encode the rule; this says the encoding must also be
-- LEARNABLE - a rule that varies by context is not one decision fewer, it is one decision
-- replaced by a thing you have to watch. ⟶ Predictable beats locally-optimal.
--
-- ⚠⚠ THE OFFER IS NOT THE STORE'S DEFAULT, AND THAT ASYMMETRY IS LOAD-BEARING.
-- `SetTrigger` stores NOTHING for `once` (§79: absent is once, so a record carries a
-- trigger only where the author chose the exception). ⟶ **Accepting the `boss` offer
-- therefore WRITES**, while accepting `note`/`say` writes nothing. A picker that "leaves
-- the default alone" would silently give every boss row `once` - the one value AL-23 says
-- a boss room must not have.
Routes.TRIGGER_OFFERED = {
    boss = "every",
    note = "once",
    say  = "once",
}

-- ★ THE READER. ⚠ It answers for an UNKNOWN word too, and answers `once` - the store's
-- default - because a word with no offer must not silently acquire the exception. The
-- completeness of the table is a SMOKE's job, not a fallback's.
function Routes.OfferedTrigger(action)
    return Routes.TRIGGER_OFFERED[action] or "once"
end

-- ★ ONE DOOR, TWO CALLERS - the row and the node take the same values, so a second setter
-- would be a second copy of one closed list.
function Routes.SetTrigger(x, trigger)
    if not x then return nil end
    if trigger == nil or trigger == "once" then
        x.trigger = nil                          -- the default stores nothing
        return nil
    end
    if not has(Routes.TRIGGERS, trigger) then return x.trigger end
    x.trigger = trigger
    return x.trigger
end

-- ⚠ RESOLVED, never read raw - `TriggerOf` answers what the runtime should DO, so an
-- absent field and an authored `once` are the same answer and cannot disagree.
function Routes.TriggerOf(x)
    return (x and x.trigger == "every") and "every" or "once"
end

-- ★ THE DOOR. ⚠ `set` is the only type that takes an N, so it is the only one that can be
-- half-stated - refused here rather than stored, for the same reason `SetRow` refuses a
-- boss name that was never offered.
function Routes.SetNext(child, nextType, nextArg)
    if not child then return nil end
    if nextType == nil then
        -- ★ CLEARING RETURNS THE NODE TO ITS DERIVED DEFAULT, and stores nothing (§79).
        -- ⚠ The arg goes with the type - *"we capture what is currently true"* - the same
        -- rule A13.3 applies to a row's action and its arg.
        child.nextType, child.nextArg = nil, nil
        return nil
    end
    if not has(Routes.NEXT_TYPES, nextType) then return child.nextType end
    if nextType == "set" and type(nextArg) ~= "number" then return child.nextType end
    child.nextType = nextType
    child.nextArg = (nextType == "set") and nextArg or nil
    return child.nextType
end

function Routes.NextOf(x)
    if not x then return nil end
    return x.nextType, x.nextArg
end

-- ★★★ IS THIS NODE A **POSITION IN THE SEQUENCE**? — ONE predicate, three callers.
--
-- Battlewrath, 2026-08-21: *"roll the step 0 to respect stage 0 in its offering. These are
-- PASSIVE DETECTORS rather than where we're pushing the players. Waypoint/supertracker is
-- for ORDINAL, where it can complete and push the user to the next ordinal stage."*
--
--     stage 0            NO   recovery is observed and corrected, never steered (AL-6)
--     step 0, a CHILD    NO   the ordinalless child is always open within its stage - a
--                             passive detector holding no position, and completing it
--                             advances nothing
--     step 0, a LONE     YES  a childless beacon is *"an item of one"* (A1.2, A12.5b) - it
--     beacon                  IS the stage's position, and completing it completes the stage
--     step > 0           YES  the ordinal is a position in a sequence
--
-- ⚠⚠ STEP 0 ALONE CANNOT SEPARATE THE FIRST TWO FROM THE THIRD - measured: an
-- ordinalless child and a childless beacon BOTH carry step 0. What separates them is
-- whether the node is a child at all, which is why the caller passes `lone`.
--
-- ★ ONE DEFINITION BECAUSE IT HAS TWO CONSUMERS: the pane (deciding whether to OFFER the
-- tick) and the manager (deciding whether to WRITE the arrow, and whether completing the
-- node advances anything). Two copies of this rule is two answers, and this file has been
-- bitten three times this week by a second copy of something.
function Routes.IsPosition(stage, step, lone)
    if not stage or stage <= 0 then return false end
    if lone then return true end
    return (step or 0) > 0
end

-- ★★ THE **LED TO** TICK (AL-19). ON by default; ticking it off is the author's choice.
--
-- ⚠ THE DEFAULT STORES NOTHING - §79's rule, the same reason `SENSE_DEFAULT` is not in
-- `SENSES`: a stored field whose only meaning is *"I did not choose"* is residue, and
-- residue travels in an export and becomes fake intent. So `nil` is ON and only an
-- author's OFF is written.
--
-- ⚠⚠ AND THE POSITION RULE IS DERIVED, NEVER STORED. A node that is not a position is
-- not led to whatever its field says - computed like `StageOf` is computed, so a stale
-- value cannot disagree with the rule. ★ It also means restaging or re-ordinalling a node
-- changes the answer with no field to remember to update.
function Routes.LedTo(stage, step, lone, node)
    if not Routes.IsPosition(stage, step, lone) then return false end
    return node == nil or node.ledTo ~= false
end

-- ★★★ THE CHAT BOX HOLDS 255 LETTERS — `FrameXML/ChatFrame.xml:21`, and `ui.lua:31`
-- already carries the citation. **Sourced, never recalled.** It lived as prose in two
-- comments and is a NUMBER here because a guard has to read it.
--
-- ★ Battlewrath, 2026-08-21: *"We can use the same chat box cap of 255. It's a known and
-- **keeps the notes from being documentaries**."* ⟶ The cap is a DESIGN choice as much as
-- a client limit - a note is a line a reader glances at mid-pull, not a page.
Routes.ARG_MAX = 255

-- ★★★ B3 · WHAT AN ARG MUST BE, KEYED ON THE **ACTION** (the Analyst's correction to
-- the bench's shape call, RI-51). ⚠ `ROW_ARG` below keys the LABEL, and a label cannot
-- hold this: `note` and `say` both declare `"content"` while their args differ in origin,
-- and a label is a PANE concern that L1.2 may rename out from under the rule.
--
-- ★★ THE ARG HAS TWO ORIGINS AND THE DECLARATION SAYS WHICH (Battlewrath, 2026-08-21):
-- *"Some is from the data set. Some is user provided. The user provided is either in-line
-- text for the chat box (capped), or for the note that will be shown."*
--
--     source = "run"    PICKED, never typed - the offer comes from the run's own bosses
--                       (A3.1). ⚠ NO CAP: the value is bounded by what the game named, and
--                       a cap on a picked value would refuse a real boss for being long.
--     source = "user"   TYPED. Capped, because untyped-length user text is the one arg a
--                       hostile or careless file can make unbounded.
--
-- ⚠ MEMBERSHIP for `source = "run"` is checkable at AUTHOR time only - a promoted route
-- drops its back-reference to the run (`routes.lua:14`) so it can travel, and an imported
-- route names another player's bosses. §459 measured that asymmetry; BUILD checks PRESENCE
-- and SHAPE, never membership.
Routes.ROW_ARG_RULE = {
    boss = { type = "string", source = "run" },
    note = { type = "string", source = "user", max = Routes.ARG_MAX },
    say  = { type = "string", source = "user", max = Routes.ARG_MAX },
    -- supertrack: absent, because it takes nothing (A2.6 - it points at the node's own
    -- position, so there is no second choice to offer).
}

-- ★ WHICH ACTIONS TAKE AN ARG, and what it is. The pane's fields follow the action word
-- (A10.3a: "fields depend on the choice"), so this is the one place that knows.
-- ⚠ `nil` means the action takes nothing - not that anything is allowed.
Routes.ROW_ARG = {
    boss       = "name",      -- picked from the run's bosses; never typed (A3.1)
    note       = "content",
    -- ⚠  LEFT (AL-19): it is the node's LED TO tick, not a verb.
    say        = "content",
}

-- ★★★ B0 / A13.1 · THE SEED — A PLACED NODE ALWAYS HAS ONE ROW: `When on`, NO ACTION.
--
-- AL-18: *"arrival IS the behaviour of a placed node"*, and there is **no fourth sense
-- word** for it - *"nothing to wait for"* describes no node we have, and `whenOn` was
-- already arrival in shipped code (`sensor.lua:46`).
--
-- ★★ WHY IT LIVES AT THIS DOOR AND NOT AT THE MINT. AL-18 asks for a
-- validate-against-a-declaration at a DOOR (WeakAuras' `PreAdd` shape), and the Analyst
-- gave the reason: **a door has no "before"**. A write in `AddBeacon` leaves a
-- WITHIN-SESSION GAP - a node made by any other path, or by a build that predates the
-- change, is unseeded until the next load. ⟶ `RowsOf` is the ONE door every reader and
-- every writer already passes through (`SetRow`, `RowIncomplete`, `ArmsWith`, the pane),
-- so there is no path that reaches a node's rows without coming through here.
--
-- ⚠ IT ALREADY MATERIALISED THE TABLE as a side effect; this makes the materialised
-- value CORRECT rather than empty. ★ That is also why `MigrateRows` and `DropRetired`
-- read `.rows` DIRECTLY and must keep doing so - a sweep that came through here could
-- never ask *"was anything authored on this node"*, because the answer would always be yes.
function Routes.RowsOf(child)
    if not child then return {} end
    child.rows = child.rows or {}
    if #child.rows == 0 then
        child.rows[1] = { sense = "whenOn" }
    end
    return child.rows
end

-- ★★ ONE SETTER (RI-17: "SetChildSense/SetChildBoss → one setter"). It writes the whole
-- declaration or it writes nothing - there is no way through this function to leave a
-- row half-stated, which is the property that makes "stored whole" true rather than
-- intended.
--
-- ⚠ `offered` keeps A3.1's law for the boss arg: the picker is fed ONLY from the run's
-- own bosses and the author cannot type a name, so an arg not on the offer is REFUSED.
-- The rest of the row is untouched by a refusal - a rejected name must not blank the
-- action the author already chose.
function Routes.SetRow(b, child, index, sense, action, arg, offered)
    if not child or not index then return nil end
    local rows = Routes.RowsOf(child)

    if sense == nil and action == nil then           -- clearing the row entirely
        table.remove(rows, index)
        return nil
    end
    if not has(Routes.SENSE_WORDS, sense) then return rows[index] end

    -- ★★★ THE ACTION IS **OPTIONAL** (AL-18). `When on` with no action means REACHED -
    -- arrival IS the behaviour of a placed node - and an action is what ELSE happens
    -- there. ⚠ A nil action was REFUSED here, one line up from where the row is written.
    --
    -- ★★ AND THE ROW IS A SERIES OF SLOTS IN FIXED POSITIONS (Battlewrath, 2026-08-21),
    -- which is what makes "optional" mean EMPTY rather than ABSENT. The grammar is
    -- `<sense>:<action>:<arg>` (RI-17) and its arity does not change: clearing the action
    -- empties slots 2 and 3 and leaves slot 1 holding. ⟶ That is why the row survives an
    -- unpick, and why nothing downstream has to ask whether a row has three parts.
    --
    -- ⚠⚠ A13.3 · **CLEARING THE ACTION CLEARS ITS ARG**, and the alternative was measured
    -- rather than assumed. WeakAuras, on changing a trigger's TYPE
    -- (`CommonOptions.lua:2024`), clears NOTHING - the old prototype's args persist
    -- forever, unread, gated by a separate `use_<name>` key. ★ Battlewrath took one half
    -- and refused the other: *"I wouldn't copy the no-pruning. As that's bloat. **We can
    -- capture what is currently true.**"*
    -- ⟶ `SetChildSense` two hundred lines up is the shipped precedent for the half we
    -- take: it clears `child.boss` with the sense - *"and the name goes with it"*.
    --
    -- ★ WITHOUT THIS THE ROW HAD NO WAY BACK. Deletion was the only exit from `boss`, and
    -- a deleted row drops the node to zero rows - which `A12.2g` now refuses at build. The
    -- author would have been unable to unpick a choice without breaking the route.
    if action == nil then
        rows[index] = { sense = sense }
        return rows[index]
    end

    if not has(Routes.ROW_ACTIONS, action) then return rows[index] end
    if action == "boss" and offered and arg ~= nil and not has(offered, arg) then
        return rows[index]                           -- not on offer (A3.1)
    end

    rows[index] = { sense = sense, action = action, arg = arg }
    return rows[index]
end

-- ⚠ TOLD, NEVER EXPORTED HALF-DONE (A3.2's mutation). A row whose action takes an arg
-- and has none is INCOMPLETE: `When on:boss:` with no name arms nothing (A3.3), so it
-- must be visible rather than shipped.
function Routes.RowIncomplete(row)
    if not row then return false end
    local want = Routes.ROW_ARG[row.action]
    if want and (row.arg == nil or row.arg == "") then return want end
    return false
end

function Routes.SetChildBoss(b, child, name, offered)
    if not child then return nil end
    if name == nil or name == "" then
        child.boss = nil
        return nil
    end
    if offered and not has(offered, name) then return child.boss end   -- not on offer
    child.boss = name
    return child.boss
end

function Routes.BossOf(child) return child and child.boss or nil end

-- ★★★ A3.3 — THE SIGNATURE IS THE GUARD, so there is no refusal anywhere.
--
-- Battlewrath's ruling, recorded in DRIVER_BASIS: *"no refusal anywhere:
-- `listen(UNIT_DIED, name)` — no name, nothing arms; editor TELLS."* The driver's
-- arming call takes the name AS ITS ARGUMENT, so a boss child with no name has nothing
-- to pass and NOTHING ARMS. The unfiltered listener cannot be expressed, because the
-- arming function has no unfiltered form.
--
-- ★ This returns exactly what would be handed to that call, and `nil` when there is
-- nothing to hand it. It is the contract stated where it can be tested, months before
-- the driver that will make the call exists.
--
-- ⚠ It is NOT a validity check and must not become one. A nameless boss child is a
-- legitimate half-authored state (S4: told, never refused) - the editor says so, the
-- walk marks the stage unrunnable, and nobody is stopped.
-- ★★ NOW READS THE ROW (RI-17). It used to ask the child's `sense` and then its `boss` -
-- two fields, set by two functions, and the pair could disagree. The declaration is one
-- thing, so this asks one thing.
--
-- ⚠ A3.3's law is UNCHANGED and is still the signature's: the driver's arming call takes
-- the name as its argument, so a `boss` row with no arg has nothing to pass and NOTHING
-- ARMS. The unfiltered listener is not refused - it cannot be expressed.
function Routes.ArmsWith(child)
    if not child then return nil end
    for _, row in ipairs(Routes.RowsOf(child)) do
        if row.action == "boss" then
            return row.arg                   -- nil when unnamed: nothing to arm with
        end
    end
    return nil
end

-- that loop. This claim was stamped at step two and did not survive step four.
function Routes.SetChildRole(b, child, role)
    if not b or not child then return nil end
    if role ~= nil and not has(Routes.ROLES, role) then return child.role end
    if role == "set" then
        for _, c in ipairs(Routes.ChildrenOf(b)) do
            if c ~= child and c.role == "set" then c.role = nil end
        end
    end
    child.role = role
    -- The set target only means anything for `set`. Cleared rather than kept, so a
    -- stale number cannot come back if the role is set again later.
    if role ~= "set" then child.setStage = nil end
    return child.role
end

-- What `set` assigns to. ⚠ Stored on the CHILD, not resolved like an outcome - this
-- is *you are at N*, where a checkpoint's outcome is *advance to N*. §84 flagged
-- that both type a number and mean different things.
function Routes.SetChildStage(b, child, n)
    if not child or child.role ~= "set" then return nil end
    local v = tonumber(n)
    if not v then return child.setStage end
    child.setStage = v
    return v
end

-- ★ `ifUnseen` is what makes `set` idempotent, the way `max` does for `complete`:
-- walk through a location you have already done and nothing happens. Default TRUE,
-- because the case it protects is the common one and the author should have to ask
-- for the sharp version.
function Routes.SetChildIfUnseen(child, on)
    if not child then return nil end
    -- ⚠ BY-EXCEPTION: only the FALSE is ever stored. The default is ON, so an absent
    -- field and a true field say the same thing - and only one of them can go stale.
    -- ⚠⚠ PLAIN IF, AND THE FIRST CUT HERE WAS THE BANNED IDIOM. I wrote
    -- `(on == false) and false or nil`, which evaluates to NIL whenever the
    -- condition is true - because the true-branch value is itself FALSE. That is
    -- the `cond and X or Y` trap this codebase has a ★★★ ruling against and bans in
    -- COA_GuardianPlates. Written into the very file that documents it, and caught
    -- by the smoke rather than by me.
    if on == false then child.ifUnseen = false else child.ifUnseen = nil end
    return Routes.ChildIfUnseen(child)
end

function Routes.ChildIfUnseen(child)
    return not (child and child.ifUnseen == false)
end

-- ★★ THE DETECT SHAPE. §84 ruled the BOX out - *"Radius does the same"* - so there
-- are two, and `wire` is a line of overlapping radii rather than a new geometry.
-- ★★★ THE CHILD'S ICON (§231) - the WORD it wears, and the only characteristic the
-- code must never read for meaning.
--
-- ★★ §225b: *"the icon is a result of the character, not the basis for it."* So this
-- writes a crop key and nothing else. The user builds a system out of the palette;
-- we attach no behaviour to the choice, and `Map.KindKey` cannot see it.
--
-- ⚠ VALIDATED AGAINST THE PALETTE, not against ART. ART carries the structural
-- crops too, and letting a child claim `beacon` would let it draw as something it
-- is not. An unknown word CLEARS rather than erroring - nil is the default crop.
function Routes.SetChildIcon(child, key)
    if not child then return nil end
    child.icon = nil
    if key then
        for _, w in ipairs(NS.Map and NS.Map.Palette() or {}) do
            if w == key then child.icon = key break end
        end
    end
    return child.icon
end

function Routes.IconOf(child) return child and child.icon or nil end

function Routes.SetChildShape(child, shape)
    if not child then return nil end
    if shape ~= nil and not has(Routes.SHAPES, shape) then return child.shape end
    child.shape = shape
    return child.shape
end

-- ⚠ THE BAND IS ASYMMETRIC (§85). `up` is the half that matters - a beacon on a
-- walkway wants reach for the player standing ON it and almost none downward, or it
-- fires for everyone underneath. Passing only `up` keeps the old symmetric meaning.
--
-- ★★★ G2 (§299, acceptance A1): A BEACON CAN CARRY A REACH TOO, and until now it
-- could not. A beacon with a radius and no children was UNRUNNABLE - it satisfied
-- itself (AcceptanceOf, below) and had no circle to be satisfied WITHIN, so the
-- simplest thing an author can want to express, *"come to this spot"*, needed a
-- child hung off it to say how close. The child stays the place for detail; the
-- beacon stops being unable to answer the only question it is ever asked.
--
-- ⚠ ONE BODY, TWO DOORS. A beacon and a child are the same shape here, so the store
-- is written once. Two copies of three lines is two places for the band to drift.
-- ★★★ RI-22 (drained 2026-08-20, §402): THE BAND IS UPWARDS ONLY.
--
-- ⚠ The block above says "the band is ASYMMETRIC (§85) - `up` is the half that
-- matters". RI-22 goes one step further and removes the other half outright, on a
-- measured reason rather than a preference: **a captured sample IS the floor.**
-- Battlewrath: *"our data points are captured from the floor level"*, and ROUTER 280
-- has a unit's z as its BASE POINT - so a downward tolerance measures nothing that
-- exists. 2.5 up covers the measured jump apex of ~1.64 (ROUTER, four flat jumps).
--
-- ★ So the option-shape question this bench filed three ways DISSOLVED rather than
-- being answered: there is no downward half to shape.
--
-- ⚠ `bandDown` is retired the way `fireOn` and `goTo` were - removed, not parked,
-- with `DropRetired` dropping and SAYING when a stored one arrives from an older
-- build or a hand-edited SavedVariables.
-- ⚠⚠ THE FLOOR IS ENFORCED HERE, WHICH IS THE ONE PLACE IT CAN BE. G2 (§299) made this
-- the single dispatch for every writer of the three reach boxes - the OnTextChanged
-- handlers and the interface registry's `set` callbacks both - so a floor on this line is
-- a floor on all of them. ★ A10.3e-R says *enforced at the picker*; a picker is a control
-- and controls multiply, so the enforcement lives under them rather than in each.
--
-- ★ CLAMPED, NOT REFUSED. An author typing 3 means *small*, and answering with 5 and a
-- visible floor is the useful reading - a refusal that blanks the box teaches nothing.
-- ⚠ A NIL RADIUS STILL PASSES THROUGH AS "unchanged", never as 5: `SetRow`-style
-- clearing is not this function's business, and turning a nil into the floor here would
-- silently repair pre-default data that `Bucket.Build` is supposed to refuse by name.
local function setReach(p, radius, up)
    if not p then return nil end
    local r = tonumber(radius)
    if r and r < Routes.R_FLOOR then r = Routes.R_FLOOR end
    -- ⚠ AND THE CEILING, at the same one place. ★ Clamped rather than refused for the
    -- same reason the floor is: a number outside the range is an author saying *bigger
    -- than that* or *smaller than that*, and answering with the bound says so.
    if r and r > Routes.R_CEILING then r = Routes.R_CEILING end
    p.radius = r or p.radius
    p.bandUp = tonumber(up) or p.bandUp
    return p.radius, p.bandUp
end

function Routes.SetChildReach(child, radius, up)
    return setReach(child, radius, up)
end

function Routes.SetBeaconReach(b, radius, up)
    return setReach(b, radius, up)
end

-- ★★★ ReachOf IS A PURE ACCESSOR: it reads x's OWN fields and asks nothing else.
-- A1.1 / T13, landed §349. N5's rule - a `<Noun>Of` reads its noun - and the
-- acceptance question composes at the call site as `ReachOf(AcceptanceOf(b))`.
--
-- ⚠⚠ WHY IT MOVED, because the old shape looked more correct than it was. ReachOf
-- used to resolve a BEACON through `AcceptanceOf`, so "the child's when present, else
-- the beacon's" was composed from a rule that already existed rather than restated -
-- which is good design and still produced this:
--
--     object.lua           the beacon pane reads `p.radius` DIRECTLY and shows it
--     routes.lua ReachOf   resolved through AcceptanceOf, so a flagged child's WON
--
-- ★ **The author types 99, the box shows 99, and the resolver returns the child's 8.**
-- A stored, displayed, inert value - and the smoke asserted the masking AS CORRECT,
-- which is how it survived a review.
--
-- ★★ AND IT IS NOT COSMETIC. Two steps on one position are two instructions with
-- DIFFERENT OWNERS, `BID` and `BID:CID`. Without both readable the flatten cannot emit
-- the beacon's own step, and a route carrying both cannot be SHARED - the far side
-- reconstructs from owner-per-instruction. A masked field is a step that cannot travel.
--
-- ★ THE MOVE CHANGED NO ANSWER, and that was asserted BEFORE it landed (§348): for
-- every fixture shape, `ReachOf(AcceptanceOf(x))` returned exactly what `ReachOf(x)`
-- used to. So this is a branch REMOVAL, and the smoke now pins the composed values so
-- it stays one.
--
-- ⚠ NO DEFAULT IS INVENTED HERE. A field nobody set comes back `nil`, not 2.5.
-- A default returned from this function would be indistinguishable from a number an
-- author typed - the one confusion the whole corpus posture exists to prevent.
-- ★ THIS SENTENCE IS STILL THE LAW, and it grew teeth: `A11.2h` (§432) deleted
-- `Rule.OPEN` and made the pure rule REFUSE a nil band rather than default one, on
-- Battlewrath's *"No infinity expressions in code. Guard by selection."*
--
-- ⚠⚠ AND THE REST OF THIS NOTE WAS WRONG BY §451 (RI-43 E3). It read: *"R2 is unruled
-- (a per-beacon band, or the +-2.5 default) … When R2 rules a default, it lands as an
-- `or` on this line and it will be the ONLY place it lives."* **All three clauses:**
--
--     R2 IS RULED         RI-22 / RI-35: the band is UPWARD ONLY, ONE VALUE, and the
--                         picker floors at 2.5 - which is the DEFAULT and the MINIMUM
--                         at once. There is no open band and no infinity to reach.
--     IT IS NOT `±`       the pair was retired with `bandDown` (§402).
--     IT IS NOT AN `or`   nor is it here. The conversion landed at **`bucket.lua`**,
--     ON THIS LINE        model row 27: *nil → 2.5, PER FIELD, at BUCKET, and the only
--                         place it may be performed.*
--
-- ★ The prediction was reasonable when written and the answer went somewhere else, which
-- is the whole reason a comment may not promise where a future thing will live. It can
-- say what it REFUSES to do - that part aged perfectly.
--
-- ⚠⚠ HEADSTONE - THE `a and b or c` TRAP MOVED TO THE CALL SITE. The branch that used
-- to live here was written as an `if` on purpose, because
--     local p = (x.kind == "beacon") and Routes.AcceptanceOf(x) or x
-- yields `x` when AcceptanceOf is nil - so a half-authored stage (children present,
-- none flagged) would fall through to the beacon and hand back a reach, reading as
-- runnable. ★ THE TRAP DID NOT DIE WITH THE BRANCH; IT RELOCATED. Any call site that
-- writes `ReachOf(AcceptanceOf(b) or b)` reintroduces it exactly. The composed form is
-- `ReachOf(AcceptanceOf(b))` and nothing else - `ReachOf(nil)` is nil, which is the
-- answer that case wants. Kept in words because there is no longer any code to guard.
function Routes.ReachOf(x)
    if not x then return nil end
    -- ⚠ TWO VALUES since RI-22, not three. A call site written `local r, up, down =`
    -- still parses and reads `down` as nil, so the arity change is source-compatible -
    -- which is exactly why the smoke asserts `select("#", ...) == 2` rather than
    -- trusting it: a re-added third value would slip back in silently.
    return x.radius, x.bandUp
end

-- ★★★ §91: THE ACTION IS AN ACT WITH A TARGET, NOT A PASSIVE CLAIM - and §85 had it
-- wrong. I modelled `waypoint` as *"I am the waypoint for this group"*, which is a
-- claim, and then made it EXCLUSIVE because one super-tracker slot cannot have two
-- owners. Battlewrath: *"Detect sits above action, so I think super tracker is the
-- action. The first detector would point action: super tracker at the pos of the
-- goto target, and then that would follow on the custody."*
--
-- ⚠⚠ THE CHAIN BELOW IS RETIRED (A2.6). It read:
--
--     A  detect -> supertrack -> target B          ★ and THAT is the outward pointing.
--     B  detect -> supertrack -> target C            Each link is one node holding
--     C  detect -> (none)              closes        another node's identity.
--
-- ★★ `supertrack` SURVIVES; its TARGET does not. "When I fire, set the tracker to
-- THERE" becomes "set the tracker HERE" - the node's own position, which is the only
-- place it can name. The model's what-happens list already called it *point here (come
-- here)*, so nothing about the author's choice changes; what goes is the second half
-- that named somebody else.
--
-- ⚠ AND THE EXCLUSIVITY COMES DOWN, same as `complete`'s did in §90 and for the same
-- reason: several children carrying the action are not two claimants fighting over a
-- slot, they each SET it at their own moment. There is nothing to arbitrate, and the
-- rule as written forbade the main use case.
--
-- ★ His own note on why the passive form is awkward, kept because it is the argument
-- FOR this one: *"there is no real escape other than 2 radiuses on the same child. 1
-- for come find me, 2 for you found me."* An act needs no escape - the next child
-- moves the tracker and the last one leaves it.
function Routes.SetChildAction(b, child, action)
    if not b or not child then return nil end
    if action ~= nil and not has(Routes.ACTIONS, action) then return child.action end
    child.action = action
    -- ⚠ A target only means something for an action that USES one. Cleared rather
    -- than kept, so a stale link cannot come back if the action is set again later.
    -- ⚠ A2.6: the `goTo` clear that lived here is gone with the field. `supertrack`
    -- now points at the node's OWN position - there is no second place to name.
    return child.action
end
-- ---------------------------------------------------------------------
-- ★★★ A2.6 (§340): OUTWARD POINTING IS GONE. Seven functions removed here.
-- ---------------------------------------------------------------------
--
--     SetChildGoTo · GoToTarget          the pointer itself
--     Heads · BrokenLinks · Cycles       the three checks that existed ONLY to
--                                        police it
--     SetChildOnRamp · OnRampOf          the entry flag, retired with it (RI-8)
--
-- ⚠⚠ REMOVED ABSOLUTELY, NOT PARKED. Battlewrath: *"a step of removing 'A
-- beacon/child can point outwards'"* — and the reason is STALE POINTERS. `goTo`
-- stored ANOTHER NODE'S IDENTITY (`child.goTo = targetId`), and it was the only
-- field that ever did. Delete a target and the pointer dangles, so something has to
-- notice: `BrokenLinks` WAS `c.goTo and not GoToTarget(b, c)` and had no other
-- purpose; `Cycles` walked `while c and c.goTo`; `Heads` computed chain heads from
-- the same links. ★ They do not become redundant - they become UNASKABLE. A cycle
-- cannot form among nodes that only point at themselves.
--
-- ★★ WHAT REPLACES IT IS ANNOUNCEMENT, NOT REFERENCE. A step announces itself at
-- the stage change; order is the ORDINAL ALONE (model §1b's sub-ratchet: step n
-- satisfied → step n+1 listens). Nothing holds anyone's id, so nothing can be
-- stale, so nothing needs checking. Self-completing.
--
-- ★ AND THE ENTRY NEEDS NO FLAG (RI-8). The order is: the stage lure · CHILD 1 is
-- the entry (the lure, the note — NOT "lowest ordinal") · then whatever the author
-- laid out fires. Child 1 is ordinarily ALSO step 1. Co-location is the rarer case,
-- and POSITION EXPRESSES THE INTENT - put them on the same spot.
--
-- ⚠ THE DOOR THAT IS LEFT MARKED, so nobody rebuilds an id-holder to get it: if a
-- satellite ever needs to jump the chain, the action is `set step N` — a NUMBER,
-- like `set stage N`, which PASSES the no-identity test. Not `activate`, not v1.
--
-- ★ The law this obeys: proposition §24 - NO NODE HOLDS ANOTHER NODE'S IDENTITY.
-- §61 dropped the run back-reference; §91 refused `b.complete = <child>` because
-- "it is a REFERENCE"; this is the last one standing.
-- ---------------------------------------------------------------------


-- ★★ `Routes.SetChildFireOn` STOOD HERE and is retired whole (A2.12a, §392).
--
-- It stored `child.fireOn` as `start | update | complete` - WHEN an action fires,
-- separately from when the child detects. ⚠ RI-5 withdrew the mechanism outright:
-- *"There is NO firing field - G15 IS the during/when-off pairing."* The sense
-- words carry it now, so a second control for the same question could only
-- disagree with them.
--
-- ⚠ It had NO CALLER - not a pane, not a smoke, not an interface row - and it is
-- removed rather than parked, which is the standing rule: half-formed code invites
-- building on it, and **this field already survived one clean-out** (A2.6 took
-- `goTo` and `onRamp` and left this behind). The drop site is in `DropRetired`.

-- ★★ WHAT THE STAGE'S ACCEPTANCE IS, in one call. §84: *"the beacon is mainly
-- listening for whichever child carried Detect: Stage complete. That's the
-- acceptance criteria and when the stage number ratchets."*
--
-- ⚠ Returns nil when the beacon has none - which is a legitimate authoring state (a
-- purely informational beacon) and an UNRUNNABLE stage. The pane must not refuse it;
-- the flatten must report it. Author freely, publish honestly.
-- ★★★ §94: A BEACON ON ITS OWN. Battlewrath, writing out what a bare beacon IS now
-- that the on-ramp exists:
--
--     "A on-ramp (come to me). A note option (give this to the player). A stage
--      ratchet when found. If it has children, it offloads that task to the one
--      made."
--
-- ★★ THREE ANSWERS, OFFLOADED INDEPENDENTLY - which is why the stairs case works: the
-- on-ramp is the top of the lift, the ratchet is a node in the combat area, and
-- neither has to be where the other is.
--
-- ⚠⚠ AND WRITING IT OUT FOUND A HOLE. §83 recorded *"the satisfier set is the
-- children, or the anchor when it has none"* and only half of that was built: this
-- returned nil for a childless beacon, so `/dr walk` reported every bare beacon as
-- UNRUNNABLE and the walk never tested one at all. `OnRampOf` had the fallback;
-- this did not. A ruling half-implemented reads exactly like a ruling honoured.
function Routes.AcceptanceOf(b)
    if not b then return nil end
    for _, c in ipairs(Routes.ChildrenOf(b)) do
        if c.role == "complete" then return c end
    end
    -- ★ The anchor is its own satisfier when it has no children. With children and
    -- none flagged, it is NOT - that is the author having offloaded the job and not
    -- finished, which is the case the unrunnable report was written for.
    if #Routes.ChildrenOf(b) == 0 then return b end
end

-- ★★ THE COUNT THAT REPLACES THE REFUSAL, and it is §81's answer in the same words:
-- report the collision at the moment it is created, never prevent it. `except` is the
-- child being edited, so the pane can say "1 other" rather than counting itself.
function Routes.RoleMatches(b, role, except)
    local n = 0
    for _, c in ipairs(Routes.ChildrenOf(b)) do
        if c ~= except and c.role == role then n = n + 1 end
    end
    return n
end

function Routes.ChildrenWithRole(b, role)
    local out = {}
    for _, c in ipairs(Routes.ChildrenOf(b)) do
        if c.role == role then out[#out + 1] = c end
    end
    return out
end

-- ---------------------------------------------------------------------
-- ★★ §78: THE OUTCOME OF SATISFACTION - the one place a checkpoint differs
-- ---------------------------------------------------------------------
--
-- Battlewrath: *"All the same mechanism. So what building the check point is, is
-- building the outcome of satisfaction to be dynamic operable."*
--
-- ONE expression, and the ratchet lives in it rather than beside it:
--
--     index = max(index, outcome)      outcome = self + 1   (default, stored as nil)
--                                              = N          (a checkpoint)
--
-- A checkpoint is not a kind of beacon. It is a beacon whose outcome you typed.
--
-- ★ THE DEFAULT STORES NOTHING, which is what keeps this dumb: only a checkpoint
-- writes a field, and what it writes is a VALUE. No beacon ever names another, so
-- there is never a second place to update. His ruling, and it is the reason the
-- literal beat binding to an identity:
--
--   *"If one beacon knows and depends on another beacon identity, that means any
--   replacement needs updating in 2 places. A stage number holds true, even if what
--   was 3 become 3, 3.1, 3.2 and then points back to 4."*
--
-- ⚠ AND `self + 1` IS ARITHMETIC, NOT "the next one in the list". Insert a 3.1 and
-- beacon 3 still promotes to 4, stepping over it. That is DELIBERATE - I proposed
-- resolving the successor instead and he refused it: *"We already have the fix for
-- that. Custom 3.1. Basically. Let the author do the mental work."* Inferring the
-- next stage would be the system deciding what the author meant.
function Routes.SetOutcome(b, n)
    if not b then return nil end
    -- nil clears back to the default rather than storing the computed number: a
    -- stored `self + 1` would go stale the moment the stage was renumbered.
    b.outcome = tonumber(n) or nil

    -- ★★★ RI-32 (drained 2026-08-20, §399): STORED, AND SAID.
    --
    -- `SetOutcome` is reachable from the pane for ANY beacon, so an author can put a
    -- checkpoint on a stageless node - where `Outcome` answers nil and the value never
    -- fires. ⚠ A2.10a's strict read STANDS; what was missing was the telling.
    --
    -- ★ Derived rather than invented: §81 forbids validation on authoring (*duplicate
    -- stages, out-of-order and fractions are all legal, the author is TOLD*), and
    -- `DropRetired` is the shipped shape for it - a value that will not be honoured is
    -- dropped AND SAID. ⚠ NOT a refusal: refusing would be GRADING the author.
    --
    -- ⚠⚠ AND THE MESSAGE HAS TO BE ACCURATE. The value is STORED and DORMANT, not
    -- lost - give the node a stage and it becomes live, because the stageless guard in
    -- `Outcome` is the only thing suppressing it. Saying "ignored" or "cleared" would
    -- send the author to re-enter something that is already there.
    -- ★ The WORDING belongs to the naming pass; A2.10a fixes what it must CONVEY.
    if b.outcome ~= nil and b.stage == nil then
        NS.Say("DungeonRun: this node has no stage, so its checkpoint is STORED but "
            .. "DORMANT - it is not lost. Give the node a stage and it takes effect "
            .. "(A2.10a)")
    end
    return b.outcome
end

function Routes.OutcomeOf(b) return b and b.outcome or nil end

-- ---------------------------------------------------------------------
-- ★★ §81: STAGE IS EDITABLE AFTER THE MINT - which is what §56 said all along.
-- ---------------------------------------------------------------------
--
-- ★★★ RULING: [CULTURE] NO validation on authoring - refusing would be GRADING the
--   author's work. Duplicate stages, out-of-order stages and fractions are all legal.
--   The author is TOLD what they are doing (match count, gaps line, running order)
--   and then trusted with it. ★ Explains several deliberate non-features.
-- ★ NO VALIDATION, DELIBERATELY. A duplicate is allowed, a stage below its
-- predecessor is allowed, a fraction is allowed. The author is told what they are
-- doing (the match count, the gaps line, the running order) and then trusted with
-- it - refusing would be grading the work, which is the one thing this addon has
-- consistently declined to do.
-- ⚠ A STAGELESS BEACON IS NOT EXPRESSIBLE TODAY, AND IT IS OWED (marked 2026-08-18,
-- Battlewrath: "to be fixed later, no impact").
--
-- ⚠ THE OFFER TABLE I RECORDED IN §366 HAS SINCE MOVED, and the basis is the version
-- that counts (NEXT, 2026-08-18): **the offer follows what EXISTS** - with a greater
-- ordinal → Step (default) · Stage · Set; the LAST step and a childless beacon → Stage
-- (default) · Set. ★ So a non-last child offers Stage too, which my §366 note did not
-- say. Corrected here rather than left as a second version of the same table.
--
-- The `Next` offer distinguishes nodes IN the stage sequence from RECOVERY nodes outside
-- it - an ordinalless child, or a STAGELESS BEACON - and a recovery node may name any
-- destination because nothing bounds it. ★ The child half already works
-- (`SetChildOrdinal(b, child, nil)` clears, which IS the satellite). The beacon half has
-- no way in: every beacon is minted with a stage (line 345, `or Routes.NextStage(id)`),
-- and the guard below keeps the old value on anything unparseable - so `nil` never lands.
--
-- ⚠ NO IMPACT TODAY, because nothing offers `Next` yet. It matters the day the
-- recovery offer is built, and this is here so that day starts by reading it rather than
-- discovering it.
function Routes.SetStage(b, n)
    if not b then return nil end
    local v = tonumber(n)
    if not v then return b.stage end          -- unparseable: keep what was there
    -- ★ S7: the SAME translation as AddBeacon's, because this is the other door to
    -- the same field and a rule that holds at one entrance is not a rule.
    if v == 0 then
        b.stage = nil
        return b.stage
    end
    b.stage = v
    return b.stage
end

-- How many OTHER beacons already sit on this number. `except` is the beacon being
-- edited, so a field showing its own stage never reports itself as a collision.
function Routes.StageMatches(id, stage, except)
    local r = Routes.Get(id)
    local n = tonumber(stage)
    if not r or not n then return 0 end
    local c = 0
    for _, b in ipairs(r.beacons) do
        if b ~= except and b.stage == n then c = c + 1 end
    end
    return c
end

-- ★ The free round numbers INSIDE the route's span - *"where the table has gaps"*.
-- Bounded by the highest stage in use, because everything above that is not a gap,
-- it is simply the next number and the ghost already offers it.
function Routes.Gaps(id, limit)
    local r = Routes.Get(id)
    if not r then return {} end
    local used, top = {}, 0
    for _, b in ipairs(r.beacons) do
        -- ⚠ `or 0` IS A NO-OP HERE TOO (RI-43 E2, §451), for TWO reasons rather than
        -- one: the report loop below runs `for n = 1, top`, and 0 can never raise `top`.
        -- ★ So a stageless beacon neither becomes a gap nor widens the search, which is
        -- what `smoke_dungeonrunpromoter`'s *"GAPS REPORTED 0"* row already pins.
        local s = b.stage or 0
        used[s] = true
        if s > top then top = s end
    end
    local out = {}
    for n = 1, math.floor(top) do
        if not used[n] then
            out[#out + 1] = n
            if limit and #out >= limit then break end
        end
    end
    return out
end

-- What satisfying this beacon promotes the index TO. Resolved, never stored.
function Routes.Outcome(b)
    if not b then return nil end
    -- ★★★ A2.10a (§393): A STAGELESS NODE DOES NOT PROMOTE THE INDEX.
    --
    -- ⚠ This line used to read `b.outcome or ((b.stage or 0) + 1)`, which answers
    -- **1** for a node with no stage - sending the player back to the START of the
    -- route on the completion of a recovery beacon. ★ It is the same shape as the
    -- `set stage N` trap: AN ABSOLUTE PROMOTION APPLIED BY A NODE THAT IS NOT IN
    -- THE SEQUENCE.
    --
    -- ★ `nil` is already the "no promotion" contract and no consumer had to change:
    -- `Driver.Promote` reads *"if not outcome then return current end"*. So the
    -- ratchet does not move, rather than moving to somewhere defensible-looking.
    --
    -- ⚠⚠ AND IT OVERRIDES A STORED `b.outcome`, deliberately and unconditionally,
    -- because A2.10a is unconditional: *"moves the ratchet NOT AT ALL."* A node
    -- outside the sequence cannot promote the sequence, whatever was stored on it.
    -- ★ An author CAN reach `SetOutcome` for such a node through the pane, so this
    -- silently ignores something they typed - FILED as RI-32 rather than decided
    -- here, since the row did not cover it.
    if b.stage == nil then return nil end
    return b.outcome or (b.stage + 1)
end

-- ★ STAGE IS A LABEL, NOT AN ARRAY POSITION - DeleteBeacon has always matched on
-- `b.stage` and left a GAP behind it, so beacons {1,2,4} is an ordinary route. Any
-- consumer indexing the table by stage number reads the wrong beacon after a single
-- delete; the driver did exactly that until §79.
function Routes.StageOrder(id)
    local r = Routes.Get(id)
    if not r then return {} end
    local out = {}
    for _, b in ipairs(r.beacons) do out[#out + 1] = b end
    -- ★★ THIS `or 0` IS LOAD-BEARING AND RULED, not a survivor of the pattern. A
    -- stageless node sorts to the HEAD, which is **RI-18 Q5's "no-stage first" falling
    -- out for free** - and `smoke_dungeonrunpromoter` asserts it by name. ⚠ Removing it
    -- here would be a behaviour change dressed as a tidy-up (RI-43 E2, classified §451).
    table.sort(out, function(x, y) return (x.stage or 0) < (y.stage or 0) end)
    return out
end

-- The beacon under test at a given index: the first one AT or ABOVE it. "At or
-- above" rather than "equal" is what lets an index land on 4 when the route jumps
-- from 3 to 7, and what makes a gap left by a delete cost nothing.
-- ⚠⚠ THE ONLY ONE OF E2's FOUR THAT CHANGES AN ANSWER, and only at **index 0**.
-- At index >= 1 a stageless beacon reads 0, fails `0 >= 1`, and is skipped - which
-- `smoke_dungeonrunpromoter` pins (*"A STAGELESS NODE WAS RETURNED FOR AN ORDERED
-- INDEX"*). At index 0 it is returned, because it sorts first and `0 >= 0` holds.
--
-- ★ E2 calls that *"the same 'a node not in the sequence acts as though it is' shape
-- A2.10a exists to refuse"*. ⚠ MEASURED, IT MAY BE RIGHT: stage 0 means ALWAYS
-- ELIGIBLE, and `Bucket.FirstStage` returns 0 for a route with no staged beacon - so a
-- caller asking for index 0 asking "what is live before the sequence starts" and being
-- handed the recovery beacon is a defensible answer, not obviously a fault.
-- ⟶ **NOTHING CALLS IT** (`emit_built_state`: test-only, *"the driver that would call
-- it does not exist"*), so the bench does not choose. The behaviour is PINNED by a row
-- so it cannot drift while the question is open, and RI-43 E2 carries the finding.
function Routes.BeaconAt(id, index)
    for _, b in ipairs(Routes.StageOrder(id)) do
        if (b.stage or 0) >= (index or 0) then return b end
    end
    return nil
end

-- ---------------------------------------------------------------------
-- ★★★ G1 (§346): THE ROUTE NOTE — the author's instructions for the runner
-- ---------------------------------------------------------------------
--
-- ★★ THE CHILD HOLDS NOTHING. The note is keyed BY the child's address; the child
-- carries no note field and no note id. **That is §24 satisfied rather than worked
-- around** — there is no reference on the node, so there is nothing that can dangle,
-- and no `BrokenNotes` check will ever need to exist. ⚠ RI-1's "re-point to share one
-- note across children" is where a reference would first appear, and it is deliberately
-- a later, separate action.
--
-- ★ REFERENCED IN THE STORE, OWNED IN THE PANE (RI-1). The author sees a text field on
-- the child and never meets a note object — no picker, no list, nothing to orphan.
-- §91's reasoning survives: with ids a note is a CONSUMER several children may one day
-- reference, and putting the string back on the child would have re-broken that.
--
-- ⚠ THE KEY IS THE ID ADDRESS, NEVER `4.1:3`. Stage and ordinal are PROPERTIES and they
-- move; `RID:BID:CID` is identity and does not (RI-6). A note keyed by the author-facing
-- path would follow the wrong child the first time anybody restaged.
-- ★ When A8.3's addressed store lands this becomes `AddressOf`; it is local until then
-- rather than front-running a design that is to be GRADED BEFORE IT IS BUILT.
local function noteKey(id, b, child)
    if not id or not b or not child or not b.id or not child.id then return nil end
    return ("%s:%s:%s"):format(tostring(id), tostring(b.id), tostring(child.id))
end

local function routeNotes() return Store and Store.RouteNoteTable() or nil end

-- ⚠ ≤ ~200 chars (A4.1, target §4). Capped HERE as well as on the box: the pane is one
-- door and the interface registry is another, and a cap that only lives on a widget is
-- a cap the second door walks around.
Routes.NOTE_MAX = 200

function Routes.SetRouteNote(id, b, child, text)
    local t, k = routeNotes(), noteKey(id, b, child)
    if not t or not k then return nil end
    if text == nil or text == "" then
        t[k] = nil                       -- A4.3: no note is a REAL state, stored as absence
        return nil
    end
    t[k] = tostring(text):sub(1, Routes.NOTE_MAX)
    return t[k]
end

function Routes.RouteNoteOf(id, b, child)
    local t, k = routeNotes(), noteKey(id, b, child)
    return (t and k) and t[k] or nil
end

-- ★ EXACTLY ONE STRING (A4.1), and it is one by construction: a table keyed by a unique
-- address cannot hold two values at one key. There is no "which note wins" question to
-- answer, which is why there is no function here to answer it.

-- ---------------------------------------------------------------------
-- Personal notes - A SEPARATE PLANE (§60)
-- ---------------------------------------------------------------------
--
-- ★ NOT PART OF A ROUTE, and that is the whole point of them. §60: "personal notes
-- will have their own note plane, with the route note plane under it." They are
-- YOURS - so they never travel with an exported route, they need no route to
-- exist, and the promoter offers them ABOVE the divider because the route selector
-- does not gate them (§61).
--
-- Keyed by mapID rather than by an id you pick, because there is one plane per
-- dungeon and nothing to choose between.
local function notes() return Store and Store.NoteTable() or nil end

function Routes.NotePlane(mapID)
    local t = notes()
    if not t or not mapID then return nil end
    t[mapID] = t[mapID] or { mapID = mapID, notes = {} }
    return t[mapID]
end

-- Read-only: does NOT create the plane. The map asks this constantly and a plane
-- minted by looking at it would put empty tables in the save file for every
-- dungeon you ever opened the map in.
function Routes.GetNotes(mapID)
    local t = notes()
    return (t and mapID) and t[mapID] or nil
end

function Routes.AddNote(mapID, node)
    local plane = Routes.NotePlane(mapID)
    if not plane or not node then return nil end
    local p = Routes.Inherit(node)
    if not p or not p.mapX then return nil end
    p.kind = "note"
    p.text = ""
    plane.notes[#plane.notes + 1] = p
    return p
end

function Routes.NoteCount(mapID)
    local plane = Routes.GetNotes(mapID)
    return plane and #plane.notes or 0
end
