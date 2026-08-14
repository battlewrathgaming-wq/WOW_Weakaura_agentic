-- harness.lua - CLIENT FIDELITY FOR THE OFFLINE STUBS.
--
-- ---------------------------------------------------------------------------
-- ★★ WHY THIS EXISTS (Battlewrath, 2026-08-14): *"Is it worth having a check list
-- of conditions to watch of how the client performs?"*
--
-- The bench runs the REAL Lua - `.tools/lua51` is 5.1.5 and WoW 3.3.5 is 5.1, so
-- LANGUAGE questions are answered exactly (§77.1's dropped backslash was settled
-- that way, against the interpreter rather than from memory).
--
-- ⚠ BUT THERE IS NO WoW API IN IT. Every frame, every handler, every SetText is OUR
-- STUB - our MODEL of the client. So an offline smoke is only ever as good as that
-- model, and the failures it cannot see are exactly the places the model and the
-- client disagree.
--
-- §81 shipped one: the real EditBox:SetText FIRES OnTextChanged, and the stub's did
-- not. `OnTextChanged -> refresh -> SetText -> OnTextChanged` is unbounded, and it
-- would have FROZEN the client rather than erroring. Nothing in the suite could
-- catch it, because the smoke called refresh() directly and never went through a
-- script handler at all.
--
-- ★ A CHECKLIST WOULD HAVE DEPENDED ON SOMEONE REMEMBERING TO RUN IT. This does not.
--
-- ★ AND THE PATTERN IS ALREADY THE HOUSE ONE - though its founding example turned
-- out to be WRONG. The map smoke's SetTexture used to reset TexCoord "because the
-- real one does". ⚠ MEASURED 2026-08-14 (SFK, api run 2): the raw texture API
-- PRESERVES the crop. §19's reset lives in a stock Lua wrapper the map never uses,
-- and the stub had generalised it to every texture - so the suite was enforcing a
-- constraint the client does not have. Battlewrath: *"otherwise we're not coding
-- towards what the runtime expects, we're coding to an abstraction of it. And that's
-- where mis-handling can exist."*
--
-- ⚠ ONLY DIVERGENCES WE CAN NAME A REASON FOR GO IN HERE. Guessing at the client
-- would replace one fiction with a more confident one, and a stub nobody can justify
-- line by line is worse than a thin one everybody distrusts.
-- ---------------------------------------------------------------------------

local H = {}

-- ★★ THE DEPTH GUARD, and it is the NECESSARY PARTNER to firing events at all.
--
-- Once a stub dispatches handlers, a re-entrant loop stops being a wrong ANSWER and
-- becomes a HANG - and a hung test is worse than no test: it reports nothing, blocks
-- the suite, and looks like an environment problem rather than a bug. The counter
-- turns it into a named failure carrying the handler that recursed.
--
-- 32 is deliberately low. Real UI code does not legitimately re-enter one handler
-- 32 times; anything that deep is a loop, not a design.
local MAX_DEPTH = 32
local depth = 0

function H.Depth() return depth end

-- Dispatch a script the way the client would: only if one is SET (rawget, because
-- the stubs' __index hands back a no-op function for every unknown key - the trap
-- that made three §77 assertions unfailable).
function H.Fire(o, name, ...)
    local fn = rawget(o, name)
    if type(fn) ~= "function" then return end
    depth = depth + 1
    if depth > MAX_DEPTH then
        -- ⚠ DECREMENT BEFORE THROWING, not zero. Every frame below us catches in its
        -- own pcall and decrements on the way out, so zeroing here would drive the
        -- counter NEGATIVE as the stack unwinds and quietly disarm the guard for the
        -- rest of the run. Symmetry is what makes it safe to trip more than once.
        depth = depth - 1
        error(("RE-ENTRANCY: '%s' re-entered %d deep. A handler is feeding itself - "
               .. "in the client this is a FREEZE, not an error."):format(name, MAX_DEPTH), 0)
    end
    local ok, err = pcall(fn, o, ...)
    depth = depth - 1
    if not ok then error(err, 0) end
end

-- ---------------------------------------------------------------------
-- The divergences, each with the reason it is here.
-- ---------------------------------------------------------------------
--
--   SetText     the real EditBox fires OnTextChanged, and does so WHETHER OR NOT
--               the value changed - which is the whole reason §81's guard has to
--               compare before writing rather than trusting SetText to be inert.
--               FontStrings never have the handler set, so this is a no-op on them.
--
--   Show/Hide   fire OnShow/OnHide, and ONLY on an actual transition. A pane that
--               refreshes itself from OnShow is ordinary, and a Show() inside that
--               refresh is the same loop shape as §81's.
--
-- ⚠ SetChecked does NOT fire OnClick in the client, and is deliberately left alone.
-- Getting that wrong in the other direction would invent a handler call that never
-- happens and send someone hunting a phantom.
--
-- ⚠ THE `-- BEHAVIOUR:` MARKERS BELOW ARE A JOIN, not decoration. They pair each
-- modelled divergence with the live experiment that measures it in
-- `COA_DevDump/task_api.lua`, and `addons/tools/check_harness.py` fails if the two
-- sets drift. Two hand-maintained lists that must agree, with nothing to notice
-- when they stop, is §63's fault - and §70's completeness walk is the answer to it.
-- Rename here, rename there.
function H.Fidelity(o)
    -- BEHAVIOUR: SetText fires OnTextChanged
    function o:SetText(t)
        self._text = t
        H.Fire(self, "OnTextChanged", self)
    end
    -- BEHAVIOUR: Show/Hide fire on transitions only
    function o:Show()
        local was = self._shown
        self._shown = true
        if not was then H.Fire(self, "OnShow") end
    end
    function o:Hide()
        local was = self._shown
        self._shown = false
        if was then H.Fire(self, "OnHide") end
    end
    return o
end

-- ---------------------------------------------------------------------
-- Modelled ELSEWHERE, and marked here so the completeness check can see them.
-- Both live in the map smoke's own stub rather than in this mixin, because they
-- predate it - but they are claims about the client all the same, and an unmarked
-- claim is one no live run will ever check.
-- ---------------------------------------------------------------------
-- BEHAVIOUR: Texture:SetTexture preserves TexCoord
-- BEHAVIOUR: SetChecked does NOT fire OnClick
-- BEHAVIOUR: SetScript replaces, never adds

-- For a smoke that wants to assert the guard itself rather than trip over it.
function H.Reset() depth = 0 end
H.MAX_DEPTH = MAX_DEPTH

return H
