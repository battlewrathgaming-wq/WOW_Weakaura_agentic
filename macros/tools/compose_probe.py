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
    lua += "}\n\nlocal TARGETS = {\n"
    for c in tgts:
        lua += f'  "{c}",\n'
    lua += "}\n"
    lua += r'''
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
