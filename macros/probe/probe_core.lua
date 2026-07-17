-- macros probe core - COMPOSED by macros/tools/compose_probe.py
-- Resident Blizzard API ONLY (every call verified present in the runtime census before
-- composing - no guessed names). No addon namespace, no globals written, NO STATE CHANGED.
-- Runs from a plain /run or the client's dev console (/luaconsole).
--
-- ============================================================================
-- THIS CAPTURE EMITS RAW OBSERVATIONS. IT DOES NOT DECIDE ANYTHING.
-- ============================================================================
-- An earlier version computed verdicts ("PROVEN-TRUE"...) in-game. That bakes ONE
-- interpretation into the capture: if the matrix is wrong, the raw is gone and the whole
-- pass must be re-run at the cost of a client session.
--   Battlewrath, 2026-07-17: "we lean into emission rather than interpretation.
--    Reasoning happens against verified facts." And: get the data set BROAD, then build
--    maps to consolidate.
-- So: land the raw returns + the context they were taken in. Verdicts are DERIVED later,
-- in a map, off this record - re-derivable forever without touching the game again.
--
-- WHY BOTH POLARITIES ARE ASKED (the derivation this feeds, for context only):
--   [combat] out of combat and [madeupword] are BOTH falsey. One reading cannot separate
--   "unsupported" from "currently false". The PAIR can. Do not collapse the pair here.
--
-- WHY THE CONTEXT STAMP: a conditional CLAIMS to reflect a game state. The context read
-- is an INDEPENDENT witness of that same state, so the map can triangulate rather than
-- assume: [combat]=false WITH inCombat=false is consistent (currently false);
-- [combat]=false WITH inCombat=true is a real anomaly (broken or unsupported). Without
-- the stamp, every context-bound flag is unreadable and the pass is half-wasted.

local function ask(clause)
  -- SecureCmdOptionParse returns (action, target); action is nil when no clause matched.
  local ok, action, target = pcall(SecureCmdOptionParse, "[" .. clause .. "] Y")
  if not ok then return nil, nil, tostring(action) end   -- action holds the error here
  return action, target, nil
end

-- RAW pair. No verdict. `pos`/`neg` are what the parser actually returned.
local function askPair(tok)
  local pa, _, pe = ask(tok)
  local na, _, ne = ask("no" .. tok)
  return { pos = pa, neg = na, pos_err = pe, neg_err = ne }
end

-- RAW target read. `target` is what the parser handed back for [@x].
local function askTarget(tok)
  local a, t, e = ask(tok)
  return { action = a, target = t, err = e }
end

-- Independent witnesses of the states the conditionals claim to reflect.
-- Every call below was verified resident against addons/maps/census/runtime/globals.json.
local function contextStamp()
  local function try(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, v = pcall(fn, ...)
    if ok then return v end
    return nil
  end
  -- UnitClass returns (localizedName, TOKEN). pcall prepends `ok`, so the TOKEN is the
  -- THIRD value - select(2,...) yields the localized name, which is the near-useless one:
  -- the TOKEN is the opaque codename that joins to Fact_basis/maps/class_table.json
  -- (SONOFARUGAL=Bloodmage etc. - unguessable, and the reason the join exists).
  local okc, className, classToken = pcall(UnitClass, "player")
  if not okc then className, classToken = nil, nil end
  return {
    taken_at        = try(GetTime),
    class           = className,
    classToken      = classToken,
    inCombat        = try(UnitAffectingCombat, "player"),
    mounted         = try(IsMounted),
    flying          = try(IsFlying),
    flyableArea     = try(IsFlyableArea),
    swimming        = try(IsSwimming),
    stealthed       = try(IsStealthed),
    indoors         = try(IsIndoors),
    outdoors        = try(IsOutdoors),
    resting         = try(IsResting),
    shapeshiftForm  = try(GetShapeshiftForm),
    actionBarPage   = try(GetActionBarPage),
    bonusBarOffset  = try(GetBonusBarOffset),
    hasVehicleBar   = try(HasVehicleActionBar),
    inVehicle       = try(UnitInVehicle, "player"),
    hasTarget       = try(UnitExists, "target"),
    hasFocus        = try(UnitExists, "focus"),
    hasPet          = try(UnitExists, "pet"),
    hasMouseover    = try(UnitExists, "mouseover"),
    targetIsDead    = try(UnitIsDeadOrGhost, "target"),
    targetHelp      = try(UnitCanAssist, "player", "target"),
    targetHarm      = try(UnitCanAttack, "player", "target"),
    numParty        = try(GetNumPartyMembers),
    numRaid         = try(GetNumRaidMembers),
    inParty         = try(UnitInParty, "player"),
    inRaid          = try(UnitInRaid, "player"),
    shiftDown       = try(IsShiftKeyDown),
    ctrlDown        = try(IsControlKeyDown),
    altDown         = try(IsAltKeyDown),
    cursorHolding   = try(GetCursorInfo),
  }
end

-- THE CONTROL ROW. Read this BEFORE anything else.
-- [@banana] is a nonsense unit. If it comes back with target="banana", `@` is a
-- PASS-THROUGH string - support lives downstream (the handler's own special-casing ->
-- Custom_HandleTerrainClick; unit resolution), the polarity matrix does NOT apply to
-- targets, and there is no [no@cursor]. If it comes back nil, `@` is validated and every
-- target row means something else entirely. ONE row decides how to read all 13.
local function controlRow()
  local a, t, e = ask("@banana")
  return { clause = "@banana", action = a, target = t, err = e,
           reads = "target=='banana' => @ is PASS-THROUGH; nil => @ is validated" }
end

-- ---- the ask, composed from the register ----
local FLAGS = {
  "actionbar",
  "actionbar:1",
  "actionbar:6",
  "advflyable",
  "bar",
  "bar:1",
  "bar:6",
  "bonusbar",
  "bonusbar:5",
  "btn",
  "button",
  "canexitvehicle",
  "channeling",
  "combat",
  "cursor",
  "dead",
  "equipped",
  "exists",
  "extrabar",
  "flyable",
  "flying",
  "form",
  "form:0",
  "form:n",
  "group",
  "group:party",
  "group:raid",
  "harm",
  "help",
  "indoors",
  "known",
  "mod",
  "mod:shift",
  "mod:ctrl",
  "mod:alt",
  "modifier",
  "modifier:shift",
  "modifier:ctrl",
  "modifier:alt",
  "mounted",
  "outdoors",
  "overridebar",
  "party",
  "pet",
  "petbattle",
  "possessbar",
  "pvpcombat",
  "raid",
  "resting",
  "shapeshift",
  "spec",
  "spec:1",
  "spec:2",
  "stance",
  "stance:0",
  "stance:1",
  "stance:2",
  "stance:n",
  "stealth",
  "swimming",
  "unithasvehicleui",
  "vehicleui",
  "worn",
}

local TARGETS = {
  "@cursor",
  "@focus",
  "@mouseover",
  "@none",
  "@party1",
  "@party4",
  "@pet",
  "@pettarget",
  "@player",
  "@raid1",
  "@raid40",
  "@target",
  "@unitId",
}

-- Returns the RAW record for the harness to land. Pure reads; no state touched.
-- Nothing here is interpreted - `flags[x].pos/.neg` are the parser's own returns, and
-- `context` is the independent witness set. The map derives verdicts from this offline.
local function run()
  local out = {
    schema  = "macros.probe.raw/1",
    context = contextStamp(),
    control = controlRow(),
    flags   = {},
    targets = {},
  }
  for _, tok in ipairs(FLAGS) do out.flags[tok] = askPair(tok) end
  for _, tok in ipairs(TARGETS) do out.targets[tok] = askTarget(tok) end
  return out
end

return run
