-- COA_DungeonRun panes_decl.lua - WHAT LIVES ON EACH ACE-RENDERED PANE, as data.
--
-- Model: addons/planning/DRIVER_BASIS.md   READ FIRST. It names what governs NOW, in
--        precedence order, and it MOVES when a ruling moves - so this line never
--        goes stale. Lower number wins; a disagreement is reported, not resolved here.
--
-- ---------------------------------------------------------------------------
-- ★★★ WHAT THIS IS, in his words (2026-08-26): *"a flat template desk side of what content
-- lives on each table of content as an inventory for the ACE rendered panes."*
--
-- One list per lane: **which controls, in what order, and for which subjects.** Nothing
-- else. It is `DR_Pane_10` as a file - *a register is a table of contents, not a defence* -
-- and the reason it can be this short is `DR_Pane_4`: placement within is the library's, so
-- there is no x, no y, no width and no height to declare.
--
-- ---------------------------------------------------------------------------
-- ★★ WHY A NEW FILE AND NOT `panespec.lua`, which is the same idea for the object pane.
--
-- Because that pane is NOT RETIRED. A10.2d forbids tearing it down to start, so `panespec`
-- must keep working exactly as it does until A10.3 replaces `object.lua` - and its cells are
-- `{ key, x, kind, width }`, a grammar with coordinates in it. ⟶ Folding this grammar into
-- that file would leave ONE file carrying TWO grammars for an unbounded period, and a reader
-- would have to know which half applied to which pane. **When `object.lua` goes, `panespec`
-- retires WHOLE with it** rather than being unpicked.
--
-- ★ What `panespec` proved is kept: a pane as DATA, checked before it reaches a client.
-- What it can no longer carry is the half `DR_Pane_4` gave to AceGUI.
--
-- ⚠ AND ITS ONE ADMITTED FRAGILITY IS NOT REPEATED. `panespec.rowHidden` is keyed by list
-- POSITION - its own comment records that inserting a row at §444 silently re-pointed every
-- entry below it. Here a control's subjects sit ON the control, so there is no index to move.
--
-- ---------------------------------------------------------------------------
-- ★★★ AND IT IS READ, NOT MIRRORED. `options.lua` BUILDS the node lane from this table; it
-- keeps no list of its own. The `layout` skill states the rule this rests on: *"The builder
-- must READ this table, not mirror it. A declaration the builder ignores is the second copy
-- that drifts."*
--
-- ⚠ THE AUTHORITY IS STILL `planning/dungeonrun_interface_inventory.md` - *"nothing reaches
-- the client that is not in here first."* This file is that authority's EXECUTABLE form, not
-- a rival to it. Where the two disagree the inventory is right and this has drifted.
-- ---------------------------------------------------------------------------

local ADDON, NS = ...

local Panes = {}
NS.Panes = Panes

-- ★★★ THREE STATES, AND THE MIDDLE ONE IS MEASURED (2026-08-26, sheet ten).
--
--     ace       a stock AceConfig type. The Dialog forms it.
--     widget    a custom AceGUI widget type WE write. The raw frames live INSIDE its
--               constructor; `OnAcquire` / `OnRelease` do the reset; `dialogControl` names
--               it from an option table.
--     frame     content that earns a window of its own - `DR_Pane_4`'s exception. The map
--               canvas: a scaled coordinate space with points at FRACTIONS of it, which no
--               Ace form expresses.
--
-- ⚠⚠ THE MIDDLE ONE WAS WRONG UNTIL THE CLIENT SAID SO. The bench spent an evening
-- measuring a `hosted` state - a raw frame parented into an Ace container - and every fault
-- it found came from keeping the composite OUTSIDE the abstraction:
--
--     seat + raw frame   stale content survives: TRUE    comes back shown: FALSE
--     widget (WA)        stale content survives: FALSE   comes back shown: TRUE
--
-- ★★ THE MODEL IS WEAKAURAS', READ FROM THE SHIPPED ADDON at Battlewrath's steer:
-- *"Review how WA handles it's templates. As they disappear once a aura is loaded. And they
-- use ace."* ⟶ `WeakAurasTemplates/TriggerTemplates.lua:1651` tears the whole template view
-- down in ONE line - `newViewScroll:ReleaseChildren()` - because every child IS a widget.
-- `AceGUIWidget-WeakAurasIconButton.lua:64-95` shows where the raw frames went: inside the
-- constructor. Thirty-one such widgets ship in `WeakAurasOptions/AceGUI-Widgets`.
--
-- ★ SO THE TEARDOWN BECOMES THE LIBRARY'S TO RUN AND OURS ONLY TO DEFINE, rather than a
-- discipline every caller must remember - which is the whole of *more repeatable*.
--
-- ⚠ THE DECISION IS STILL NOT THIS FILE'S. `concepts/type-or-feature.md` decides whether a
-- given display is a TYPE (a second, unrelated instance already exists) or one pane's
-- FEATURE. This list only makes the moment visible; `Panes.Unformable()` names what is
-- waiting on that decision, and UI-4 carries it to the seat that owns the registry.
Panes.ACE_KINDS = {
    ["select"] = true, ["input"] = true, ["toggle"] = true, ["range"] = true,
    ["execute"] = true, ["description"] = true, ["header"] = true, ["color"] = true,
    ["keybinding"] = true, ["multiselect"] = true, ["group"] = true,
}

-- ★ SUBJECTS, and they are AL-60's: *"the subject is the selection. So a beacon (or child)
-- or a node on the map from Run."* A control names which subjects it applies to; `any`
-- means every selection, and ABSENT means the control does not depend on one at all.
Panes.SUBJECTS = { "beacon", "child", "note", "runnode" }

Panes.lanes = {

    -- =================================================================
    -- ★★★ THE NODE EDITOR - A10.2a's three survivors, folded §687.
    -- =================================================================
    -- A10.2a's order is the row's own: *"`object.sense` · `object.ordinal` · `object.note`
    -- FIRST - the three the checker cannot see today AND the three that SURVIVE into the
    -- node editor."* The rest of the object pane is REPLACED by A10.3, never folded.
    node = {
        order = 3,
        -- ⚠ `name` IS A CODE TERM, resolved through the adaptor at build time. A display
        -- string typed here would be the private word table A10.2's precondition retired.
        title = "node editor",
        controls = {
            { key = "sense",   kind = "select", word = "sense",     subjects = "any",
              desc = "what this node is listening for" },
            { key = "ordinal", kind = "input",  word = "ordinal",   subjects = { "child" },
              desc = "its place in the line; empty means OUT of the line" },
            -- ★★★ BEACON OR CHILD ONLY — Battlewrath, 2026-08-27: *"so far Beacons and
            -- Children of Beacons are the only thing that exist that can be STATEFUL to
            -- deliver a note."* ⚠ This read `subjects = "any"`, which admitted `note` and
            -- `runnode` — and `note` is the PERSONAL MAP PIN, so the route-instructions box
            -- was offered on the very object RI-10 separated it from.
            { key = "note",    kind = "input",  word = "routeNote",
              subjects = { "beacon", "child" },
              multiline = true,
              desc = "what this node tells the reader" },
        },
        -- ☐ A10.3's controls land here NEXT, assembled per subject in
        -- `driver_architecture.md` §4d (AI-40 → AL-65). ⚠ NOT LISTED YET, deliberately:
        -- AL-65 names NEXT's store field as owed (`nextType`/`nextArg`, AL-21) and rules
        -- *"the control lands WITH its field, never ahead of it"*.
    },

    -- =================================================================
    -- ⚠⚠ CURATION AND PROMOTION ARE DECLARED EMPTY, AND THE EMPTINESS IS THE RECORD.
    -- =================================================================
    -- ★ Neither has a ruled control list anywhere on disk. A10.2a says curation's bar folds
    -- LAST; promotion's contents are named nowhere the bench has found. ⟶ So they carry a
    -- `blocked` line rather than an invented list.
    --
    -- ★★ AN EMPTY LANE WITH A REASON IS NOT THE SAME AS A MISSING ONE. `trace-what-we-know`:
    -- name where the data stops and classify the gap. Both of these are GATHER, not ACCEPT -
    -- someone has to rule them, and this file says who and from what.
    curate = {
        order = 1,
        title = "curation",
        controls = {},
        blocked = "A10.2a folds editor.lua's curation bar LAST, and its contents are the "
               .. "bar's rather than a ruled list. The order is the ruling; the list is not.",
    },

    promote = {
        order = 2,
        title = "promoter",
        controls = {},
        blocked = "no ruled control list exists. Battlewrath, 2026-08-25: *\"Promote is "
               .. "currently the route builder. Probably a user facing name later.\"* - a "
               .. "name and a job, not an inventory. Assembling one from the rulings is the "
               .. "shape AL-65 used for A10.3 and is the architect's, not the bench's.",
    },
}

-- ★ ONE PLACE ANSWERS *does this control apply to this subject*. A consumer branching on
-- `subjects` itself would be a second reading of the same field, and the two can disagree.
-- ⚠ NO SUBJECT AT ALL is not the same as `any`: a control with no `subjects` key does not
-- depend on a selection, so it is never disabled for want of one.
function Panes.Applies(control, kind)
    if not control or control.subjects == nil then return true end
    if control.subjects == "any" then return kind ~= nil end
    for _, s in ipairs(control.subjects) do
        if s == kind then return true end
    end
    return false
end

-- ★★ WHAT THIS DECLARATION ASKS FOR THAT ACE CANNOT DRAW. Returns one entry per control
-- whose `kind` is outside `ACE_KINDS` - each one a surface asking `DR_Pane_4`'s question.
-- ⚠ IT IS A REPORT, NEVER A REFUSAL. A declared-but-unformable control is the bench being
-- AHEAD of the decision, not behind it: the inventory is allowed to name a thing before
-- anyone has ruled how it draws, and that is the whole point of writing the contents down
-- first. What must not happen is it reaching a client unnoticed.
function Panes.Unformable()
    local out = {}
    for _, lane in ipairs(Panes.Lanes()) do
        for _, c in ipairs(Panes.lanes[lane].controls) do
            if not Panes.ACE_KINDS[c.kind] then
                out[#out + 1] = lane .. "." .. tostring(c.key)
                    .. " (" .. tostring(c.kind) .. ")"
            end
        end
    end
    return out
end

-- ⚠ SORTED, so two readers of this table get the same order. `pairs` is unordered in Lua and
-- a lane list that reshuffled per run would make every diff of a built pane meaningless.
function Panes.Lanes()
    local out = {}
    for k in pairs(Panes.lanes) do out[#out + 1] = k end
    table.sort(out, function(a, b)
        return (Panes.lanes[a].order or 0) < (Panes.lanes[b].order or 0)
    end)
    return out
end

return Panes
