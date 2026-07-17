-- macros probe core - COMPOSED by macros/tools/compose_probe.py
-- Resident Blizzard API ONLY. No addon namespace, no globals written, no state changed.
-- Runs from a plain /run or the client's dev console (/luaconsole).
--
-- READ THE VERDICTS, DO NOT GUESS THEM:
--   [X] true , [noX] false -> PROVEN-TRUE    known, currently true
--   [X] false, [noX] true  -> PROVEN-FALSE   known, currently false
--   [X] false, [noX] false -> UNSUPPORTED    parser rejects both ways
--   [X] true , [noX] true  -> IGNORED        no-op / not evaluated
--
-- The pair is the whole point: one reading cannot distinguish "unsupported" from
-- "currently false", and a naive probe would report half the vocabulary as missing.
--
-- CAVEAT the addons bench should keep: a verdict is TRUE OF THE MOMENT IT RAN.
-- [combat] out of combat is PROVEN-FALSE, not unsupported - which the pair handles -
-- but [flying]/[mounted]/[indoors] etc. are context-bound. Re-run in a second context
-- (mounted, in combat, indoors) to separate "false here" from "always false".

local function ask(clause)
  -- SecureCmdOptionParse returns (action, target); action is nil when no clause matched.
  local ok, action, target = pcall(SecureCmdOptionParse, "[" .. clause .. "] Y")
  if not ok then return nil, nil, "ERROR" end
  return action, target, nil
end

local function verdict(pos, neg)
  if pos and neg then return "IGNORED" end
  if pos and not neg then return "PROVEN-TRUE" end
  if neg and not pos then return "PROVEN-FALSE" end
  return "UNSUPPORTED"
end

-- FLAGS: polarity pairs.
local function probeFlag(tok)
  local a = ask(tok)
  local b = ask("no" .. tok)
  return verdict(a ~= nil, b ~= nil)
end

-- TARGETS: pass-through test, NOT polarity. Returns what the parser handed back.
local function probeTarget(tok)
  local action, target = ask(tok)
  return (action ~= nil), target
end

-- THE CONTROL ROW. Ask this FIRST and read it before anything else:
-- if [@banana] comes back with target="banana", then @ is a PASS-THROUGH string and
-- the vocabulary question does not apply to targets at all. If it comes back nil, @ is
-- validated and every @ row means something different. One row, and it decides how to
-- read all 13 target rows.
local function controlRow()
  local action, target = ask("@banana")
  return { clause = "@banana", action_nonnil = (action ~= nil), target = target,
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

-- Returns a flat result table for the harness to land. Pure reads; no state touched.
local function run()
  local out = { control = controlRow(), flags = {}, targets = {} }
  for _, tok in ipairs(FLAGS) do out.flags[tok] = probeFlag(tok) end
  for _, tok in ipairs(TARGETS) do
    local nonnil, target = probeTarget(tok)
    out.targets[tok] = { action_nonnil = nonnil, target = target }
  end
  return out
end

return run
