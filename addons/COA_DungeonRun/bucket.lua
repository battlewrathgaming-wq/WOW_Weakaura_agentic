-- Model: addons/planning/DRIVER_BASIS.md · construction is `driver_data_model.md` §A5b
--
-- ★★★ BUCKET (rows 23-27) — how a stored route becomes a thing the driver can run.
--
-- Battlewrath's direction, quoted in §A5b: *"stage the material that fit within the current
-- gate… by the time it's sampling it should have a target in mind."*
--
--     BUCKET   once per run.   Read the offered store WHOLE, keep this MAP for relevance,
--                              pick the RID, lay the route out as ONE BUCKET PER STAGE.
--     STAGE    per advance.    Hand the current stage's bucket, WITH stage 0, to the sensor.
--
-- ⚠⚠⚠ ROW 24 IS THE ONE THAT SHAPES THIS FILE: **BUCKET MAY FAIL, AND SHOULD FAIL LOUDLY.
-- STAGE MAY NOT FAIL.** A stage advance happens MID-RUN, MID-COMBAT, and is raised by the
-- sensor's own output — there is no good answer available at that moment. ★ So every check
-- this file can perform, it performs HERE, and it names what was missing rather than
-- returning an empty list. *"If STAGE can fail, BUCKET did not do its job."*

local NS = select(2, ...)
NS = NS or _G.COA_DungeonRun_NS or {}
if select(2, ...) == nil then _G.COA_DungeonRun_NS = NS end

local Bucket = {}
NS.Bucket = Bucket

-- ★ Row 27's per-field defaults, named once. ⚠ NOT one sweep: `nil` means "no constraint"
-- in both cases and the two land on OPPOSITE ends of the number line.
--
--     stage / step   nil → 0      a gate you must MATCH relaxes to 0 (always eligible)
--     band           nil → 2.5    the author did not pick; 2.5 is the picker's FLOOR and
--                                 DEFAULT at once (RI-35)
--
-- ⚠⚠ A blanket `nil → 0` would give every unpicked band a tolerance of ZERO — `dz` exactly 0
-- — the most restrictive value producible from an absence that means "unset".
Bucket.ALWAYS = 0
-- ★★ READ FROM THE CONTRACT, not held here (RI-81, 2026-08-26). `contract.lua` already
-- declares this field's type, its optional-ness and its why; the VALUE an author gets by
-- choosing nothing belongs in the same place. ⚠ The literal stays as a fallback only for
-- the load-order case where `contract.lua` has not run - and it is the SAME number, so a
-- drift between them is impossible rather than merely unlikely.
-- ⟶ The CONVERSION stays here and only here (A11.2h): `rule.lua` refuses a nil band
-- rather than defaulting one, so this is the single place a nil becomes a number.
Bucket.BAND_DEFAULT = (NS.Contract and NS.Contract.Seed
                       and NS.Contract.Seed("characteristic", "band")) or 2.5

-- ⚠⚠ A DECLARED SEAM, not an omission. Row 25 says BUCKET resolves every `action` id to
-- *"the function the runtime holds"*. ★ THE RUNTIME HOLDS NO SUCH FUNCTIONS: `adaptor.lua`
-- carries a VOCABULARY (`Word` / `Has` / `Codes`) and there are no handlers anywhere, and
-- the sensor brief's own fence puts the action's HANDLING outside this lane —
-- *"we generate the input contract, never the consumer's handling."*
-- ⟶ So what is resolved here is the id against the KNOWN VOCABULARY, and an unknown one is
-- a BUCKET failure. That satisfies row 25's stated rule — **nothing authored is ever
-- interpreted on the hot path** — which is the part that is ours. Binding a callable is a
-- later step, and it goes through this seam rather than around it.
Bucket.Resolve = nil

-- ★★★ THE AUTHORABLE SET IS THE AUTHORITY, NOT THE DISPLAY VOCABULARY (§457).
--
-- ⚠⚠ THIS CHECKED `Adaptor.Has` AND THAT WAS WRONG, measurably: `adaptor.lua` is the
-- `code -> user word` LOOKUP (A5.1) and carries a word for `supertrack` only, while
-- `Routes.ROW_ACTIONS` is `{ boss, note, supertrack, say }`. ⟶ **THREE OF FOUR AUTHORABLE
-- ACTIONS WERE REFUSED AT BUILD.** Same on the sense side: `Routes.SENSE_WORDS` is
-- `{ whenOn, seen, whenOff }` and the adaptor names none of them.
--
-- ★ The two tables answer different questions and only one of them is a gate:
--
--     Routes.ROW_ACTIONS   MAY AN AUTHOR WRITE THIS?   the gate - `SetRow` uses it too
--     Adaptor.Word(code)   WHAT DOES A HUMAN SEE?      display; A5.1 PASSES A MISS THROUGH
--
-- ⚠ A miss in the adaptor is explicitly NOT an error - it *"passes through the code term"*
-- - so treating one as a refusal turned a cosmetic gap into a route that will not build.
-- ⟶ `SetRow` is the shipped precedent and it checks the same two lists this now checks.
--
-- ★★★ B4 (AL-17) · THE CLOSED LIST IS CONSULTED **BEFORE** THE RESOLVER, NEVER INSTEAD.
--
-- ⚠⚠ THIS READ `if Bucket.Resolve then return Bucket.Resolve(...) end` AND RETURNED
-- INSTEAD OF CHECKING. The bench found it while measuring a hostile route (§464) and
-- reported it rather than deciding it; AL-17 closed it BY DEFINITION:
--
--     *"`fn` the consuming addon's own callable, resolved through the closed list it
--      publishes, the resolver consulted AFTER that check and never instead of it."*
--
-- ★ The order IS the guarantee. Battlewrath's line is what it protects: *"the build
-- process and what that means in code expression would be owned by the users own addon,
-- not what the authoring addon states is capable."* ⟶ A route may NAME a verb from the
-- closed list; a resolver may then say what that named verb IS. A resolver that could be
-- reached with an unlisted word would let the FILE choose the vocabulary, which is the
-- whole thing the list exists to prevent.
--
-- ⚠ A miss in the adaptor is explicitly NOT an error - it *"passes through the code term"*
-- - so treating one as a refusal turned a cosmetic gap into a route that will not build.
-- ⟶ `SetRow` is the shipped precedent and it checks the same two lists this checks.
local function known(kind, code)
    local Routes = NS.Routes
    local list = Routes and (kind == "sense" and Routes.SENSE_WORDS or Routes.ROW_ACTIONS)
    if not list then return nil, "no vocabulary is loaded" end

    local listed = false
    for _, w in ipairs(list) do
        if w == code then listed = true; break end
    end
    if not listed then return nil, "unknown " .. kind end

    -- ★ ONLY NOW. The word is one the consumer published; what it RESOLVES TO is the
    -- consumer's to say, and a resolver returning nil is a refusal like any other.
    if Bucket.Resolve then return Bucket.Resolve(kind, code) end
    return code
end

local function num(v)
    return type(v) == "number" and v == v and v ~= math.huge and v ~= -math.huge
end

-- ★ Row 9: BEACON STAGES ARE WHOLE NUMBERS ONLY. ⚠ The row itself records that the rule has
-- no enforcement — the mint cannot produce a fraction but three other doors accept one, and
-- *"the guard arrives with the pickers (A10.3e)"*. ⟶ BUCKET is a door those three feed, and
-- row 24 says a failure belongs here rather than mid-run, so it refuses one.
local function wholeStage(v)
    return num(v) and v >= 0 and math.floor(v) == v
end

-- =====================================================================
-- ★★★ BUILD — one route, one map, ONE BUCKET PER STAGE holding BARE ROWS (row 23).
--
-- Returns `bucket, nil` or `nil, reason`. ⚠ NEVER an empty bucket standing in for a
-- failure: row 24's whole point is that the caller learns WHAT was missing, and "no
-- beacons" and "the route is for another map" must not arrive looking alike.
-- =====================================================================
function Bucket.Build(mapID, rid, routes)
    local Routes = routes or NS.Routes
    if not Routes then return nil, "no route store" end
    if mapID == nil then return nil, "no mapID" end
    if rid == nil then return nil, "no route id" end

    local r = Routes.Get(rid)
    if not r then return nil, ("no such route: %s"):format(tostring(rid)) end

    -- ★ RELEVANCE IS THE MAP, and the check is here because it cannot be anywhere later.
    -- `Routes.List(mapID)` is the shipped precedent (`routes.lua:335-341`) — the editor
    -- already offers an authored route against a map by exactly this test.
    if r.mapID ~= mapID then
        return nil, ("route %s is for map %s, not %s")
            :format(tostring(rid), tostring(r.mapID), tostring(mapID))
    end

    local out = { mapID = mapID, rid = rid, stages = {}, count = 0, bounced = 0 }
    local beacons = r.beacons or {}
    if #beacons == 0 then
        return nil, ("route %s has no beacons"):format(tostring(rid))
    end

    -- ★★★ A12.2b · ONE ANCHOR PER STAGE, and this is the RUNTIME half of a guarantee
    -- whose author-time half does not exist yet. The picker (A10.3e) will make duplicates
    -- unauthorable; until then THREE doors still accept a second (`promoter.lua:530`'s
    -- free-text box, `AddBeacon`, `SetStage`) and tell-and-trust holds at those doors -
    -- a swap, never a refusal (§90 S4).
    -- ⟶ **The refusal belongs HERE instead**, so the manager never meets a duplicate
    -- whether or not the pickers have landed, and an IMPORTED pre-slot route meets it too.
    -- ★ F2/AL-9 sequenced it BEFORE the manager: *"the window is closed at the cost of one
    -- refusal before the part that relies on it exists."*
    --
    -- ⚠⚠ STAGE 0 IS EXEMPT, and it must be. RI-40: bucket 0 is the PASS-THROUGH and
    -- *"every recovery will be pooled in the same bucket as a catch all"* - so many beacons
    -- at stage 0 is the ruled shape, not a duplicate. The guarantee is about POSITIONS IN
    -- THE SEQUENCE, and stage 0 is not one.
    local anchored = {}

    for _, b in ipairs(beacons) do
        -- ⚠ Row 10 / row 27: the STORE holds `nil` and the RECORD holds `0`. The conversion
        -- happens HERE and only here. ★ The store keeps nil because absence must stay LOUD —
        -- `nil + 1` throws where `0 + 1` silently returns 1, which is A2.10a's defect.
        local stage = b.stage
        if stage == nil then
            stage = Bucket.ALWAYS
        elseif not wholeStage(stage) then
            return nil, ("beacon %s has a fractional stage (%s); stages are whole numbers")
                :format(tostring(b.id), tostring(stage))
        end

        if stage ~= Bucket.ALWAYS then
            local first = anchored[stage]
            if first then
                -- ★ NAMED, AND IT NAMES THE FIX. Row 24 wants the reason to say what was
                -- missing; here what is missing is a DECISION, so the reason says where to
                -- make it. ⚠ Never tolerance and never a shared cursor: RI-41 measured what
                -- a shared cursor does - completing one beacon's step strands the other's.
                return nil, ("two beacons at stage %s (%s and %s) - re-slot in the editor")
                    :format(tostring(stage), tostring(first), tostring(b.id))
            end
            anchored[stage] = b.id
        end

        -- ★★★ A CHILDLESS BEACON IS THE NODE. ⚠⚠ §433 REFUSED ONE — *"beacon %s has no
        -- children to sample"* — and that was a DEFECT, not a strictness. `A1.2` is a
        -- governing acceptance row: **"A childless beacon is RUNNABLE"**, and `A2.5` says
        -- why in the store's own terms: when the last child is deleted *"its tabs RETURN to
        -- the parent, which is childless again and behaves as its own single child."*
        -- `A2.6` closes it — an ordinal child is *"the same object as a childless beacon"*.
        -- ⟶ So the beacon carries its own position, its own reach and its own rows, and the
        -- shipped `Routes.AcceptanceOf` already encodes exactly this: *"the anchor is its
        -- own satisfier when it has no children."*
        --
        -- ⚠ THE BENCH BUILT AGAINST `ChildrenOf` BECAUSE THAT IS THE ACCESSOR IT KNEW,
        -- rather than against the row that governs. Battlewrath asked the question that
        -- found it: *"or sense the childless beacon (A bucket with one item)"* — which is
        -- precisely what this now produces, one node under its beacon's stage.
        -- ★ READ, NOT RE-DERIVED. `Routes.StandsAlone` is the one body for A2.6's clause;
        -- this line used to compute `#kids == 0` itself, which RI-54 carried as *"one rule,
        -- two bodies"*. The comment above still explains WHY the beacon stands alone - that
        -- is reasoning, and it belongs here; the ANSWER comes from the rule.
        local kids = Routes.ChildrenOf(b)
        local lone = Routes.StandsAlone(b)
        if lone then kids = { b } end

        -- ★★★ BUCKET 0 IS SLICED: WHERE STAGE = 0, A `BID:CID` BOUNCES.
        --
        -- Battlewrath, 2026-08-20: *"it'd be sliced at Bucket 0, so where Stage = 0 BID: if
        -- CID bounce."* · *"beacon 0 are locked out of having children. Self completing only.
        -- **A stage can still have 0 to solve for in a stage.**"*
        --
        -- ⚠⚠ A BOUNCE, NOT A REFUSAL, and the difference is the whole design. The bench
        -- proposed refusing the BUILD (row 24, fail loudly) and that was the worse answer: it
        -- would break every existing route carrying one and raise a migration question. ★ A
        -- bounce is the GATE doing its ordinary job — a `CID` under stage 0 does not match, so
        -- it is not admitted, and the route still builds.
        --
        -- ★★ WHY THE SLICE EXISTS (§437, measured): stage 0 is taken WHOLESALE, so a sequence
        -- authored under a recovery beacon had EVERY step armed at once — the fault §436 fixed
        -- at stage level, alive inside stage 0. ⟶ The collision was never a flaw in either
        -- rule; **it was a shape that should not exist.** With no `CID` admitted at stage 0,
        -- "taken wholesale" and "an ordinal is a POSITION IN A SEQUENCE" never meet.
        --
        -- ⚠ THE TWO ZEROS ARE DIFFERENT, and this is the line that separates them:
        --      STAGE 0  the recovery beacon   → `BID` only, self-completing
        --      STEP 0   an ordinalless child  → UNTOUCHED, still the pass-through
        --
        -- ⚠ TOLD, NOT SILENT (§90 S4). `bounced` counts them so a caller can say so; dropping
        -- them without a number would be the quiet kind of correct.
        -- ⚠ THE BID IS ADMITTED; ONLY THE CID BOUNCES. A first cut emptied `kids` and lost
        -- the BEACON too — but *"BID: if CID bounce"* keeps the `BID` and drops the `CID`,
        -- and that is the useful reading as well as the literal one: the recovery beacon
        -- still runs, it just loses a sequence that never sequenced anything.
        -- ★ It becomes `lone` — literally the self-completing item A1.2 describes, and
        -- `AcceptanceOf`'s *"the anchor is its own satisfier when it has no children"*.
        -- ⚠ If that beacon has no reach of its own it now REFUSES on "no radius", loudly and
        -- correctly: A2.5 moves a beacon's tabs to child 1 when it gains children, so a
        -- stage-0 beacon with children may genuinely have nothing left to be found by.
        if stage == Bucket.ALWAYS and not lone then
            out.bounced = out.bounced + #kids
            kids, lone = { b }, true
        end

        -- ★★ NAME THE THING THAT IS ACTUALLY MISSING. ⚠ When the beacon IS the node
        -- (`lone`), there is no child — and §441's `inspect_route` run on the RFC scrape
        -- showed BUCKET saying *"child 1 of beacon 1 has no radius"* against a beacon with
        -- ZERO children. ★ Row 24 wants the refusal to name what was missing; naming a child
        -- that does not exist sends the reader looking for something to give a radius to.
        -- Same class as the invented `CID` in the address, one message over.
        local function who(c)
            if lone then return ("beacon %s"):format(tostring(b.id)) end
            return ("child %s of beacon %s"):format(tostring(c.id), tostring(b.id))
        end

        for _, c in ipairs(kids) do
            -- ★ THE ORDINAL IS THE STEP, AND IT IS A FIELD ON THE ROW — never a table key
            -- (model row 23, corrected). An ordinalless child carries **Step 0**, which is
            -- always-eligible as a VALUE rather than a slot: several items may hold Step:0
            -- and they are simply several rows that each read 0.
            local step = c.ordinal
            if step == nil then
                step = Bucket.ALWAYS
            elseif not num(step) or step < 0 then
                return nil, ("%s has an unusable ordinal (%s)")
                    :format(who(c), tostring(c.ordinal))
            end

            local radius, bandUp = Routes.ReachOf(c)
            if not num(radius) or radius <= 0 then
                return nil, ("%s has no radius"):format(who(c))
            end
            -- ⚠⚠ ROW 27's BAND CONVERSION, AND IT IS THE ONLY PLACE IT MAY HAPPEN (A11.2h).
            -- `rule.lua` REFUSES a nil band rather than defaulting one — `Rule.OPEN` was
            -- deleted because *"no infinity living in code to ever reach that"*. ★ So an
            -- unresolved node fires NOWHERE, and this line is what stops that being the
            -- normal case rather than a fault.
            -- ⚠ VALIDATED BEFORE DEFAULTED, and the order matters. Written the other way
            -- round the negative check ran on the ALREADY-DEFAULTED value, so it could
            -- never see a bad one — and it compared a possible `nil`. ★ Mutation found it:
            -- dropping the default crashed on `band < 0` instead of reaching a named
            -- refusal, which is row 24's failure mode exactly (a fault that does not say
            -- what it is). ⟶ An AUTHORED band is checked; only ABSENCE gets the default.
            if bandUp ~= nil and (not num(bandUp) or bandUp < 0) then
                return nil, ("%s has a negative or unusable band (%s)")
                    :format(who(c), tostring(bandUp))
            end
            local band = num(bandUp) and bandUp or Bucket.BAND_DEFAULT

            if not (num(c.x) and num(c.y) and num(c.z)) then
                return nil, ("%s is unplaceable"):format(who(c))
            end

            -- ★ ROW 25's SHARE: every authored id is checked against the vocabulary NOW, so
            -- the 1 Hz pass never meets a word it has to look up or wonder about.
            local rows = {}
            for i, row in ipairs(Routes.RowsOf(c)) do
                -- ★★★ THE ACTION IS OPTIONAL (AL-18), IN BOTH DOORS - this is the second.
                --
                -- `When on` with no action means REACHED: arrival IS the behaviour of a
                -- placed node, and an action is what ELSE happens there. ⚠ The SENSE is
                -- not optional, and that asymmetry is the rule rather than an oversight -
                -- a row with no sense is nothing listening, which is not a row at all.
                --
                -- ★★ A ROW IS SLOTS IN FIXED POSITIONS (Battlewrath, 2026-08-21), so an
                -- absent action is an EMPTY SLOT and the row keeps its arity. Everything
                -- below reads slot by slot and none of it has to ask how many parts
                -- arrived.
                --
                -- ⚠ NO NO-OP WORD ENTERS `ROW_ACTIONS` for this. AL-18 is explicit: the
                -- closed capability list stays untouched, because a route that could NAME
                -- "do nothing" would be naming a verb, and the list is the security
                -- boundary (§464). Absence is not a capability.
                local action, why
                if row.action ~= nil then
                    action, why = known("action", row.action)
                    if not action then
                        return nil, ("%s, row %d: %s (%s)")
                            :format(who(c), i, why or "unknown action",
                                    tostring(row.action))
                    end
                end
                -- ★★★ AN ACTION THAT TAKES AN ARG AND HAS NONE IS NOT A ROW, IT IS A NO-OP.
                -- A3.3: `When on:boss:` with no name **arms nothing**. ⟶ Row 24 makes that
                -- BUCKET's to refuse, loudly, rather than the driver's to discover at the
                -- moment it dispatches.
                --
                -- ⚠⚠ MEASURED BEFORE IT WAS WRITTEN (§458): `boss` with no name, `boss` with a
                -- BLANK name and `say` with no content all BUILT. `Routes.RowIncomplete`
                -- named every one of them and was consumed by nothing but its own smoke -
                -- **an author-time guard with no runtime counterpart.**
                --
                -- ★ `Routes.ROW_ARG` is *"the one place that knows"* which actions take an
                -- arg and what it is, so the refusal NAMES THE FIELD - `no name` reads very
                -- differently from `incomplete row` when it arrives mid-run.
                -- ⚠ The empty string counts as missing, and `SetRow` is the precedent:
                -- `RowIncomplete` refuses `arg == ""` exactly as it refuses nil.
                -- ⚠ AN ACTIONLESS ROW DECLARES NO ARG, and it needs no test to say so:
                -- reading `ROW_ARG[nil]` is nil in Lua, so `want` is nil and neither guard
                -- below fires. ★ THE SAME read-a-declaration shape `ROW_ARG.supertrack = nil`
                -- already ships - AL-18 named it as the reason no new mechanism was needed.
                -- ⚠⚠ A defensive `action and` STOOD HERE and mutation proved it dead: broken
                -- deliberately, nothing failed, because it could never change an answer.
                -- ★★★ B3 · THE ARG IS THE SHAPE ITS ACTION DECLARES, AND THE GUARD
                -- **READS** THE DECLARATION (AL-17). ⚠ A route is untrusted input - it
                -- travels by design - and the VERB side is closed while the VALUE side
                -- was not: measured, a `boss` arg could be a table, a number or a boolean
                -- and every one built (§464).
                --
                -- ★★ HIS PRECEDENT, CONFIRMED ON THE FORK: *"user input for the CLEU is
                -- just raw text called by the log reader for the filter."* WeakAuras
                -- declares `sourceName` as `type = "string"` and hands it to a scanner
                -- that turns it into LOOKUP TABLE KEYS - a COMPARAND, never code and
                -- never a Lua pattern. `ROW_ARG_RULE` is our `type = "string"`.
                --
                -- ⚠ IT READS RATHER THAN RESTATES. A guard spelling out `"string"` per
                -- action is a COPY, and §457/§458 are two consecutive commits where a copy
                -- of a vocabulary drifted from the shipped one - the second within a day.
                local rule = Routes.ROW_ARG_RULE and Routes.ROW_ARG_RULE[action]
                local want = Routes.ROW_ARG and Routes.ROW_ARG[action]
                if want and (row.arg == nil or row.arg == "") then
                    return nil, ("%s, row %d: the action %s has no %s")
                        :format(who(c), i, tostring(action), tostring(want))
                end

                -- ★★★ B3 · AND IT MUST BE THE SHAPE ITS ACTION DECLARES.
                --
                -- ⚠⚠ A route is UNTRUSTED INPUT, and that follows from a FEATURE rather
                -- than from suspicion: `routes.lua:14` drops the run back-reference so a
                -- route can reach *"someone else's machine"*. ⟶ The VERB side was already
                -- closed - `known()` admits only a published word - and this is the VALUE
                -- side, which was the half that leaked: measured, a `boss` arg could be a
                -- table, a number or a boolean and every one built (§464).
                --
                -- ★★ HIS PRECEDENT, CONFIRMED ON THE FORK: *"user input for the CLEU is
                -- just raw text called by the log reader for the filter."* WeakAuras
                -- declares `sourceName` as `type = "string"` and hands it to
                -- `ParseNameCheck`, a hand-written scanner that turns the text into LOOKUP
                -- TABLE KEYS - a COMPARAND, never code and **never a Lua pattern**.
                -- `Routes.ROW_ARG_RULE` is our `type = "string"`.
                --
                -- ⚠ IT READS THE DECLARATION RATHER THAN RESTATING IT. A guard spelling
                -- out `"string"` per action is a COPY, and §457/§458 are two consecutive
                -- commits where a copied vocabulary drifted from the shipped one - the
                -- second within a day of fixing the first.
                if rule and row.arg ~= nil and type(row.arg) ~= rule.type then
                    return nil, ("%s, row %d: the %s for %s must be %s, not a %s")
                        :format(who(c), i, tostring(want), tostring(action),
                                tostring(rule.type), type(row.arg))
                end

                -- ★★ CAPPED WHERE A PERSON TYPES IT. Battlewrath, 2026-08-21: *"the same
                -- chat box cap of 255. It's a known and **keeps the notes from being
                -- documentaries**."* ⟶ The number is `FrameXML/ChatFrame.xml:21` - sourced,
                -- not recalled - and the cap is a DESIGN limit as much as a client one: a
                -- note is a line glanced at mid-pull, not a page.
                -- ⚠ A `source = "run"` arg carries NO cap, deliberately: it was PICKED
                -- from what the game named, so a cap could refuse a real boss for being
                -- long. The declaration says which is which.
                if rule and rule.max and type(row.arg) == "string"
                   and #row.arg > rule.max then
                    return nil, ("%s, row %d: the %s for %s is %d letters, over the %d "
                                 .. "the chat box holds")
                        :format(who(c), i, tostring(want), tostring(action),
                                #row.arg, rule.max)
                end

                local sense = known("sense", row.sense)
                if not sense then
                    return nil, ("%s, row %d: unknown sense (%s)")
                        :format(who(c), i, tostring(row.sense))
                end
                -- ★★★ A12.2f · NO SILENT ORPHAN. A behaviour row whose address resolves
                -- to no characteristic is REFUSED, named - never carried, never dropped.
                --
                -- ⚠ Nothing WRITES a `cid` onto a row today: a row lives under its child, so
                -- the address is implicit. **An orphan arrives on IMPORT** - A11.1a
                -- reconstructs by matching the node prefix, so a row naming a `cid` with no
                -- characteristic behind it is exactly what a hand-edited or partial export
                -- produces.
                -- ★ Why it belongs to the isolation demonstration (RI-23): the manifest's
                -- whole claim is *"what can be true right now"*, and a behaviour row whose
                -- node does not exist is a row that can NEVER be true. Carrying it silently
                -- is the confusion between lookalike tables that isolation exists to prevent.
                if row.cid ~= nil and row.cid ~= c.id then
                    return nil, ("%s, row %d: address %s:%s resolves to no characteristic")
                        :format(who(c), i, tostring(b.id), tostring(row.cid))
                end
                -- ★ THE ROW'S OWN LATCH, resolved the same way (AL-23: *"each action
                -- needs its own latch"*). A boss row and a note row on ONE node can differ.
                rows[i] = { sense = sense, action = action, arg = row.arg,
                            trigger = Routes.TriggerOf and Routes.TriggerOf(row) or "once" }
            end

            -- ★★★ ONE BUCKET PER STAGE, AND ITS ENTRIES ARE BARE ROWS (model row 23).
            --
            -- ⚠⚠ §433-§439 BUILT `bucket[stage][step]` AND THAT WAS WRONG. Battlewrath:
            -- *"The bucket itself is the stage… The steps are the bare rows. A stage
            -- childless is an item of one."*
            --
            --     Bucket stage 0        (always listened to)
            --     Bucket stage 1        Beacon
            --     Bucket stage 2        Child · Child · Child
            --
            -- ★★★ AND THIS IS WHAT DISSOLVED RI-41, structurally rather than by a rule.
            -- The `[step]` level was the thing that put `left:l1` and `right:r1` in ONE
            -- SLOT — *"left right is a construction of implementation and isn't expressed
            -- in authoring"*. ⟶ It was a construction of THIS implementation. With bare
            -- rows there is no slot to share: each row carries its own address and its own
            -- ordinal, and nothing pairs two beacons' children by number.
            --
            -- ⚠ `Stage:Step` IS NEVER COMPOSED IN HERE: *"The bucket is the stage address.
            -- Per item is the steps."* The pair is DECOMPOSED at runtime, not built.
            -- ★★★ B2 / A12.2g · A NODE WITH NO BEHAVIOUR RECORDS IS REFUSED, BY NAME.
            --
            -- ⚠⚠ IT CAN NEVER COMPLETE. `manager.lua`'s ledger holds a node until ALL its
            -- tabs are done, and a node with none has no tab that can ever be done - so
            -- the run ARMS, POINTS THE ARROW AND NEVER ADVANCES. ★ Row 24's whole
            -- complaint: a failure the driver discovers mid-run, silently, instead of one
            -- BUCKET names at build.
            --
            -- ★★ AND IN PRODUCTION THIS IS UNREACHABLE, which is the point rather than a
            -- reason to drop it. `Routes.RowsOf` seeds every node with an arrival row
            -- (A13.1), so nothing the addon AUTHORS can arrive here empty. This guard is
            -- for the files the addon did NOT write - a hand-edited SavedVariables or an
            -- import from another build - the same two sources `routes.lua:194` names for
            -- every other retired-field sweep.
            --
            -- ⚠ SEQUENCE: the seed lands FIRST. Shipped alone this refuses the entire
            -- existing corpus - §462's probe measured every authored route at zero rows -
            -- which is why RI-51 put B0 in front of it and why B1 runs at load before this
            -- is ever reached.
            if #rows == 0 then
                return nil, ("%s carries no behaviour rows, so it can never complete")
                    :format(who(c))
            end

            local slot = out.stages[stage]
            if not slot then slot = {}; out.stages[stage] = slot end
            slot[#slot + 1] = {
                x = c.x, y = c.y, z = c.z, mapID = c.mapID or mapID,
                r = radius, band = band,
                stage = stage, step = step,
                -- ★★ AN ITEM OF ONE (A1.2 · A12.5b). ⚠ Carried because STEP 0 CANNOT SAY
                -- IT: an ordinalless CHILD and a CHILDLESS BEACON both arrive here as step
                -- 0, and they are opposites - the child is a passive detector holding no
                -- position, the beacon IS its stage's position. Only the address arity
                -- distinguished them before, and parsing an address to recover a fact the
                -- builder already knew is the shape that goes stale.
                lone = lone or nil,
                -- ★ `Next` RIDES THE CHARACTERISTIC RECORD (data model A1.1), beside POS,
                -- R and Band - absolute values resolved at AUTHORING time and handed to the
                -- driver. ⚠ Absent stays absent: the DERIVATION is the manager's, and
                -- writing a default here would store a decision the author did not make.
                nextType = c.nextType, nextArg = c.nextArg,
                -- ★ THE NODE'S LATCH (AL-23) - whether it stays in the offered list once
                -- it has completed. ⚠ RESOLVED here, so the manager never meets an absent
                -- field and an authored `once` as two different things.
                trigger = Routes.TriggerOf and Routes.TriggerOf(c) or "once",
                ledTo = Routes.LedTo and Routes.LedTo(stage, step, lone, c) or nil,
                -- ★★ A CHILDLESS BEACON'S NODE HAS NO CID, and the contract says so:
                -- `cid` is `optional = true` (`contract.lua:63`). ⚠ The first cut formatted
                -- all four parts unconditionally, so a lone beacon addressed itself as
                -- `mapID:rid:solo:solo` — **inventing a child id by duplicating the
                -- beacon's.** An address is the whole ancestry (row 2, *"ownership IS the
                -- address"*); a repeated segment claims a child that does not exist.
                -- ★ Mutation found it: swapping the lone node for a fabricated child
                -- SURVIVED, because the beacon id appeared either way.
                address = lone
                    and ("%s:%s:%s"):format(tostring(mapID), tostring(rid), tostring(b.id))
                    or ("%s:%s:%s:%s"):format(tostring(mapID), tostring(rid),
                                              tostring(b.id), tostring(c.id)),
                rows = rows,
            }
            out.count = out.count + 1
        end
    end

    return out, nil
end

-- =====================================================================
-- ★★ STAGE (row 23's second phase) — hand the current stage's bucket, WITH stage 0.
--
-- ⚠⚠ IT CANNOT FAIL, AND THAT IS ROW 24 RATHER THAN AN OVERSIGHT. Every check lives in
-- `Build`; this walks two already-formed tables and concatenates them. ★ Row 26: the swap
-- re-evaluates nothing, because all stage buckets were formed at BUCKET time.
-- =====================================================================
-- ★★★ THE FIRST STAGE, DERIVED FROM THE DATA — and it is derived precisely so it does not
-- have to take a side in a disagreement the bench must not resolve.
--
-- ⚠⚠ `A11.5a` says *"V1 has no stage"*. `Routes.AddBeacon` MINTS one for every beacon
-- (`b.stage = want or Routes.NextStage(id)`) and only an explicit `0` request stores nil.
-- ⟶ Both cannot be true of the same route, and *"don't mutate code from doc disagreement"*.
--
-- ★ So this answers *"where does a run start?"* from what is actually in the bucket, and is
-- correct under EITHER reading:
--     a route with no stages   → every node converted to 0 → first stage is 0, all of it
--     a route with stages 1..N → first stage is 1, plus stage 0 (row 23)
-- ⚠ Stage 0 is *"always eligible"*, NOT "the first stage" — a recovery beacon is not where a
-- run begins. So the lowest POSITIVE stage wins when one exists.
-- ★★★ THE NEXT STAGE **PRESENT IN THE ROUTE**, never `+1` (A12.5a, corrected by AL-9).
--
-- ⚠⚠ `+1` IS A DEFECT AND THE BRIEF SAYS WHY: DR_UI_3 permits an exposed gap, so stages
-- 1, 2, 5 are legal, and `+1` from 2 arms stage 3 - which `Bucket.Stage` resolves to
-- **bucket 0 alone, so the run stalls with only recovery armed.** ★ A scan cannot make
-- that mistake; arithmetic on a sparse set can.
--
-- ★ ONE DEFINITION OF "lowest positive above N", so `FirstStage` is this from zero. Two
-- separate scans is two places for the ALWAYS-is-not-first rule to drift apart.
function Bucket.NextStage(bucket, after)
    if type(bucket) ~= "table" or not bucket.stages then return nil end
    local floor = num(after) and after or Bucket.ALWAYS
    local best
    for stage in pairs(bucket.stages) do
        if stage > floor and stage > Bucket.ALWAYS and (not best or stage < best) then
            best = stage
        end
    end
    return best
end

-- ★ THE NEXT POSITIVE ORDINAL WITHIN A STAGE (A12.5a's `Step`). ⚠ Returns nil when the
-- ordinal RUNS DRY, and that nil is not an error - A12.5b makes it the stage's completion.
function Bucket.NextStep(bucket, stage, after)
    if type(bucket) ~= "table" or not bucket.stages then return nil end
    local slot = bucket.stages[stage]
    if not slot then return nil end
    local floor = num(after) and after or Bucket.ALWAYS
    local best
    for _, row in ipairs(slot) do
        local s = row.step
        if s and s > floor and s > Bucket.ALWAYS and (not best or s < best) then best = s end
    end
    return best
end

-- ⚠ STAGE 0 IS NOT "THE FIRST STAGE" (A12.3a, and §435's walk found it by failing): a
-- recovery beacon is not where a run begins. It is the FALLBACK when no positive stage
-- exists at all, which is a route of recovery beacons only.
function Bucket.FirstStage(bucket)
    return Bucket.NextStage(bucket, Bucket.ALWAYS) or Bucket.ALWAYS
end

-- ★★★ THE LOWEST POSITIVE STEP IN A STAGE — where a stage starts, same shape as
-- `FirstStage`. ⚠ Step 0 is the PASS-THROUGH, not the first step: an ordinalless child is
-- always open within its stage, which is not the same as being first in the sequence.
-- ⚠ SCANS THE ROWS' `step` FIELDS, not table keys - there are no step keys any more.
function Bucket.FirstStep(bucket, stage)
    return Bucket.NextStep(bucket, stage, Bucket.ALWAYS) or Bucket.ALWAYS
end

function Bucket.Stage(bucket, stage, step)
    local out = {}
    if type(bucket) ~= "table" or not bucket.stages then return out end
    local want = num(stage) and stage or Bucket.ALWAYS
    local wantStep = num(step) and step or Bucket.ALWAYS

    local function push(list)
        for _, node in ipairs(list or {}) do out[#out + 1] = node end
    end

    -- ★★ BUCKET 0 IS THE PASS-THROUGH, TAKEN WHOLESALE. Battlewrath, 2026-08-20: *"Stage 0
    -- is the pass through. Always valid bucket. So every recovery will be pooled in the same
    -- bucket as a catch all."* ⚠ No step filter inside it — a catch-all that filtered by step
    -- would not be a catch-all, and a recovery beacon has no position in the sequence to hold.
    push(bucket.stages[Bucket.ALWAYS])

    -- ★★★ WITHIN THE CURRENT STAGE THE STEP IS GATED THE SAME WAY THE STAGE IS: **0 or an
    -- exact match**, everything else BOUNCES. His table, at step 3:
    --
    --         0 ← check     the ordinalless children; *"their ordinal is not constructed"*
    --         1 ← bounce
    --         2 ← bounce
    --         3 ← check     the current position
    --         4 ← bounce
    --
    -- ⚠⚠ AND THE REASON IS CORRECTNESS, NOT COST — his words: *"if it's checking every step
    -- in a ordinal, it can complete every ordinal. Which is counter to what the ordinal gating
    -- is. **It's a position in a sequence.**"* ⟶ With every step armed, a player who walks
    -- past step 3 while standing at step 1 COMPLETES step 3, and the sequence stops being one.
    -- ★ §435 handed out every step of the current stage. That was the bug, and it was invisible
    -- to every test because no fixture had a player reach a step out of order.
    -- ⚠⚠ THE STEP IS NOW A FILTER OVER ROWS, not a second index. `0 or an exact match`
    -- is unchanged as a RULE; what changed is that it is read off each row rather than
    -- looked up. ★ Same bounce, one level.
    if want ~= Bucket.ALWAYS then
        for _, node in ipairs(bucket.stages[want] or {}) do
            local s = node.step or Bucket.ALWAYS
            if s == Bucket.ALWAYS or s == wantStep then out[#out + 1] = node end
        end
    end
    return out
end

return Bucket
