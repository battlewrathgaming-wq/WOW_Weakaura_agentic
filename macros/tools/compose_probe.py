r"""
compose_probe.py - compose the LIVE PROBE from the question register.

reference/candidates.json (the QUESTIONS) -> probe/ (the ask, the method, the Lua core)

The probe is the ONLY channel that can close `basis/conditionals.json`. The conditional
vocabulary is C-side (SecureCmdOptionParse is called 49x in ChatFrame.lua and defined
NOWHERE in Lua; the runtime census buckets it stock-capi), and the attested-usage seed
measured ZERO - the client's own shipped code uses no conditional literal anywhere. So
there is no source read that reaches it. Only asking the live client does.

LANE (Battlewrath, 2026-07-17): the macros bench COMPOSES the probe (what to ask, how to
read the answer). The ADDONS bench OWNS configuring COA_DevDump and will set up the
harness - "they own configuring coadump". This tool emits the PAYLOAD + the evaluation
CORE, not a coadump task file. Handing facts across the lane, not doing their build.

WHY THE POLARITY PAIR: `[combat]` out of combat and `[madeupword]` are BOTH falsey.
Unsupported and currently-false are INDISTINGUISHABLE from one reading, so a naive probe
silently reports half the vocabulary as missing. Testing both polarities and reading the
PAIR turns an ambiguous silence into a verdict.

WHY TARGETS ARE ASKED DIFFERENTLY: `@unit` and `[flag]` are not the same mechanism.
`@unit` looks like a pass-through STRING (support lives downstream in the handler and unit
resolution), so the polarity matrix does not apply - there is probably no [no@cursor].
ONE row settles that: [@banana].

Anti-cheat: the core uses ONLY resident Blizzard API - no addon namespace, no new file
needed to test. It runs from a plain /run, or interactively in the client's built-in dev
console (/luaconsole, /devconsole - CONFIRMED present by Battlewrath 2026-07-17).

Usage:
    py macros\tools\compose_probe.py
"""
import json
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
REF = ROOT / "macros" / "reference" / "candidates.json"
OUT = ROOT / "macros" / "probe"

# The verdict matrix. This IS the method - a probe without it cannot tell "unsupported"
# from "currently false", which is the entire difficulty.
MATRIX = {
    "X=true,  noX=false": "PROVEN-TRUE     known, currently true",
    "X=false, noX=true": "PROVEN-FALSE    known, currently false",
    "X=false, noX=false": "UNSUPPORTED     parser rejects BOTH polarities",
    "X=true,  noX=true": "IGNORED         both true => no-op / not evaluated",
}

LUA_CORE = r'''-- macros probe core - COMPOSED by macros/tools/compose_probe.py
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

-- RAW target read. TWO channels, because a target has two independent questions:
--   1. does the PARSER pass @X through?      -> SecureCmdOptionParse
--   2. does the unit system RESOLVE X?       -> UnitExists / UnitName
-- If @ is pass-through (the control row decides), the parser NEVER decides whether @X
-- works - the UNIT SYSTEM does, downstream. So the vocabulary question for targets is
-- answered by UnitExists, NOT by the polarity matrix. `cursor` is the proof: it is in NO
-- unit-token list on any wiki, because it was never a unit - it is a macro-layer special
-- case (Legion 7.1.0) that Ascension hand-rolls via Custom_HandleTerrainClick.
-- Indexed bases are probed at index 1 (party1, raid1, nameplate1...); a bare base like
-- "party" is not itself a unit.
local function askTarget(tok, unitProbe)
  local a, t, e = ask(tok)
  local exists, name, guid
  if unitProbe then
    local ok1, v1 = pcall(UnitExists, unitProbe); exists = ok1 and v1 or nil
    local ok2, v2 = pcall(UnitName, unitProbe);   name   = ok2 and v2 or nil
    local ok3, v3 = pcall(UnitGUID, unitProbe);   guid   = ok3 and v3 or nil
  end
  return { action = a, target = t, err = e,
           unit_probe = unitProbe, unit_exists = exists, unit_name = name,
           unit_guid = guid }
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
  local okm, numAcct, numChar = pcall(GetNumMacros)
  if not okm then numAcct, numChar = nil, nil end
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

    -- MACRO LIMITS - settles the Lua layer of a real conflict in the client's OWN code:
    -- Blizzard_MacroUI declares GLOBAL MAX_CHARACTER_MACROS=36, while
    -- QuickKeybindActionPicker declares a LOCAL 18 (the stock WotLK value) shadowing it in
    -- that one file. Addons read the GLOBAL (Asc_MacroBank: `MAX_CHARACTER_MACROS or 18`),
    -- so if the global is 36 the picker is the odd one out and likely cannot see character
    -- macros 19-36 - a candidate real bug in the backported picker.
    -- These reads settle what the LUA layer says. They do NOT settle what the ENGINE
    -- enforces; that needs a write test (create macro 19+), which is out of scope for a
    -- pure-read pass and is NOT asked here.
    maxAccountMacros   = MAX_ACCOUNT_MACROS,
    maxCharacterMacros = MAX_CHARACTER_MACROS,
    maxMacros_legacy   = MAX_MACROS,     -- the pre-WotLK global; nil expected on 3.3.5a
    -- GetNumMacros returns (accountCount, charCount). pcall prepends `ok`, so the values
    -- are the 2nd and 3rd - select(1,...) would hand back the BOOLEAN. Same trap as
    -- UnitClass's token, hit twice in one session; write it out rather than be clever.
    numMacros_account  = numAcct,
    numMacros_char     = numChar,
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
'''


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    reg = json.load(open(REF, encoding="utf-8"))
    cands = reg["candidates"]

    flags = {t: e for t, e in cands.items() if e["kind"] == "flag"}
    targets = {t: e for t, e in cands.items() if e["kind"] == "unit-target"}

    rows = []
    for t, e in sorted(flags.items()):
        forms = [t] + [f"{t}:{a}" for a in e["arg_forms"]]
        for f in forms:
            rows.append({
                "ask": f, "kind": "flag", "method": "polarity-pair",
                "clauses": [f, f"no{f}"],
                "base": t, "arg": f.split(":", 1)[1] if ":" in f else None,
                "era_signal": e["era_signal"],
                "patch_added": _added_patch(e),
                "priority": priority(e),
                "expect_note": expectation(e),
                "verdict": None,
            })
    for t, e in sorted(targets.items()):
        rows.append({
            "ask": t, "kind": "unit-target", "method": "pass-through test",
            "clauses": [t], "base": t, "arg": None,
            "era_signal": e["era_signal"],
            "patch_added": _added_patch(e),
            "priority": priority(e),
            "expect_note": expectation(e),
            "source_witness": e.get("source_witness"),
            "verdict": None,
        })

    payload = {
        "what": "THE ASK - every question the live probe puts to the client, with the "
                "method for reading each answer. Verdicts are null until the probe runs.",
        "composed_by": "macros/tools/compose_probe.py",
        "composed_at": datetime.now().isoformat(timespec="seconds"),
        "from_register": {
            "file": "macros/reference/candidates.json",
            "candidates": len(cands),
            "sources": list(reg["sources"]),
        },
        "verdict_matrix": MATRIX,
        "two_mechanisms": reg["two_mechanisms"],
        "control_row": {
            "ask": "@banana",
            "why": "decides how to read ALL 13 target rows. If a nonsense unit returns "
                   "target='banana', @ is a PASS-THROUGH string and the vocabulary "
                   "question does not apply to targets at all. Run and read this FIRST.",
        },
        "standing_limits": {
            "asked_only": "A probe proves only what it ASKS. This ask-list came from the "
                          "wiki chain, so the rim stays OPEN - the output is a proven set "
                          "with an honest rim, NEVER an enumeration.",
            "true_of_the_moment": "A verdict is true of the CONTEXT it ran in. "
                                  "PROVEN-FALSE means 'false right now', not 'unsupported' "
                                  "- the pair separates those. But context-bound flags "
                                  "(flying, mounted, indoors, combat, stance:N) want a "
                                  "SECOND run in a different context to be meaningful.",
            "absence_proves_nothing": reg["absence_proves_nothing"],
        },
        "counts": {
            "rows": len(rows),
            "flag_rows": sum(1 for r in rows if r["kind"] == "flag"),
            "target_rows": sum(1 for r in rows if r["kind"] == "unit-target"),
            "by_priority": {p: sum(1 for r in rows if r["priority"] == p)
                            for p in ("1-backport-test", "2-undated-test", "3-baseline",
                                      "4-corroborate")},
        },
        "rows": rows,
    }
    with open(OUT / "probe_rows.json", "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=1, ensure_ascii=False)
        f.write("\n")

    clauses = [r["ask"] for r in rows if r["kind"] == "flag"]
    tgts = [r["ask"] for r in rows if r["kind"] == "unit-target"]
    lua = LUA_CORE + "\n-- ---- the ask, composed from the register ----\n"
    lua += "local FLAGS = {\n"
    for c in clauses:
        lua += f'  "{c}",\n'
    # {clause, unitProbe}: unitProbe is the BARE token handed to UnitExists. Indexed bases
    # are probed at index 1 (a bare "party" is not itself a unit). nil = not a unit token
    # at all - which is exactly what `cursor` is: no wiki lists it as a unit, because it
    # never was one.
    INDEXED = ("party", "raid", "arena", "boss", "partypet", "raidpet", "nameplate",
               "spectated", "spectatedpet")
    lua += "}\n\n-- { clause, unitProbe } - unitProbe is the bare token for UnitExists;\n"
    lua += "-- indexed bases probe index 1; nil = not a unit token (e.g. cursor).\n"
    lua += "local TARGETS = {\n"
    for c in tgts:
        bare = c.lstrip("@")
        probe = ("nil" if bare in ("cursor", "unitId")
                 else (f'"{bare}1"' if bare in INDEXED else f'"{bare}"'))
        lua += f'  {{ "{c}", {probe} }},\n'
    lua += "}\n"
    lua += r'''
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
  for _, row in ipairs(TARGETS) do out.targets[row[1]] = askTarget(row[1], row[2]) end
  return out
end

return run
'''
    (OUT / "probe_core.lua").write_text(lua, encoding="utf-8")

    print(f"composed -> {OUT}")
    print(f"  probe_rows.json  {len(rows)} rows "
          f"({payload['counts']['flag_rows']} flag / {payload['counts']['target_rows']} target)")
    for p, n in payload["counts"]["by_priority"].items():
        print(f"    {p:18} {n}")
    print(f"  probe_core.lua   {len(clauses)} flag clauses, {len(tgts)} target clauses")


def _added_patch(e):
    for h in e.get("patch_history") or []:
        if h["action"] == "added":
            return h
    return None


def priority(e):
    """Rank by INFORMATION, and only off evidence.

    An earlier version ranked off era_signal == "post-wotlk" - a label inferred from
    ABSENCE in the ~2010 archive. That label is gone: absence was never evidence. Rank
    now off SOURCED patch dates, and treat the undated bucket as its own honest tier
    rather than smuggling it in as a backport claim.
    """
    p = _added_patch(e)
    if p and int(p["patch"].split(".")[0]) > 3:
        return "1-backport-test"            # SOURCED as postdating the 3.3.5a base
    if e["era_signal"] == "retail-documented-only":
        return "2-undated-test"             # we genuinely do not know when it shipped
    if e.get("source_witness"):
        return "4-corroborate"
    return "3-baseline"


def expectation(e):
    p = _added_patch(e)
    if p and int(p["patch"].split(".")[0]) > 3:
        cite = " (Blizzard-cited)" if p.get("cited") else ""
        return (f"SOURCED: added in patch {p['patch']} ({p['expansion']}){cite} => POSTDATES "
                f"the 3.3.5a base, so it is here only if BACKPORTED. This client backports "
                f"freely, and @cursor - itself 7.1.0 Legion - is a CONFIRMED backport "
                f"witnessed in CoA's own source. Highest information per row.")
    if e["era_signal"] == "retail-documented-only":
        return ("UNDATED. A retail wiki lists it, the ~2010 archive does not, and NO patch "
                "annotation exists. We do NOT know when it shipped - absence is not "
                "evidence. It may predate 3.3.5a and simply be undocumented there. The "
                "probe answers; no wiki can.")
    if e["era_signal"] == "archive-documented":
        return ("documented in the ~2010 archive (WotLK/early-Cata) => expected present on a "
                "3.3.5a base. An UNSUPPORTED here would be a real finding (removed or "
                "never implemented on this fork).")
    if e["era_signal"] == "NOT-IN-ANY-WIKI":
        return ("found ONLY in this client's own Lua. No wiki mentions it - which is exactly "
                "why a wiki's absence proves nothing.")
    return "claimed only by the Ascension wiki"


if __name__ == "__main__":
    main()
