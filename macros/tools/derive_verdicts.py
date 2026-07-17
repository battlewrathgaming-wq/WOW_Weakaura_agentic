r"""
derive_verdicts.py - the MAP. Landed raw captures -> verdicts -> basis/conditionals.json.

reference/candidates.json (questions) + addons/landing/records/*__macros.json (RAW answers)
    -> basis/conditionals.json  (the PROVEN set)
    -> reference/candidates.json proof_marks (written back)

This is the only path anything becomes fact in this slice. It runs OFFLINE against the
landed raw, so a wrong rule costs a re-derivation - never another client session. That was
the whole point of landing raw instead of verdicts.

============================================================================
THE CAPTURE INVALIDATED THE DESIGNED MATRIX. THE DATA IS RIGHT; THE MATRIX WAS WRONG.
============================================================================
probe/README + basis/conditionals.json shipped this matrix:

    [X] false, [noX] false  ->  UNSUPPORTED   "parser rejects both polarities"

**That row NEVER OCCURS.** Across 5 contexts x 63 flags there is not a single both-nil.
The parser does NOT reject an unknown conditional - it IGNORES it and the clause PASSES:

    unknown X   ->  [X] = "Y"  (clause passes) ,  [noX] = nil
    known-true X->  [X] = "Y"                  ,  [noX] = nil     <-- IDENTICAL

So the polarity pair CANNOT distinguish unsupported from currently-true. The designed
discriminator does not discriminate.

PROOF (mechanical, not inference): [petbattle] reads TRUE in all five contexts. Pet battles
are MoP 5.0; there is no pet battle system in a 3.3.5a client and certainly none running.
[resting] reads TRUE in all five while the stamp's IsResting() is falsey in all five - a
DIRECT CONTRADICTION between the conditional and an independent witness of the same state.

WHAT SAVES THE PASS: the CONTEXT STAMP and FIVE contexts - the parts added late, on
Battlewrath's "get the data set broad" and "triangulate" steer. Without them this capture
would have reported ~10 retail-only conditionals as PROVEN-TRUE and graduated them into the
basis as fact. The stamp is the only reason the map is not confidently wrong.

============================================================================
THE DERIVATION THE DATA ACTUALLY SUPPORTS
============================================================================
Because unknown => passes:

  1. reads FALSE in ANY context           -> EVALUATED, therefore SUPPORTED.
                                             An ignored clause can never read false.
                                             This is the STRONGEST signal we have.
  2. VARIES across contexts               -> SUPPORTED-PROVEN. It tracked real state.
  3. any ARG-SIBLING reads false          -> the BASE is evaluated -> SUPPORTED
                                             ([spec:2]=F proves [spec:N] is real, even
                                             though [spec:1] is constant-true.)
  4. constant TRUE + a stamp witness that
     says the state is FALSE              -> UNSUPPORTED (ignored). Contradiction.
  5. constant TRUE + stamp corroborates   -> SUPPORTED-TRUE, but WEAK: indistinguishable
                                             from ignored on this evidence alone. Say so.
  6. constant TRUE + no witness           -> AMBIGUOUS. Do NOT guess. Name it.

Usage:
    py macros\tools\derive_verdicts.py
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RECORDS = ROOT / "addons" / "landing" / "records"
REF = ROOT / "macros" / "reference" / "candidates.json"
BASIS = ROOT / "macros" / "basis"

# Human labels, from addons/landing/records/20260717_contexts.md (Battlewrath, live).
# The runIds are the join key; the labels are HIS, not derived.
CONTEXTS = {
    "20260717_041925_853": "rest",
    "20260717_042043_345": "spell-form",
    "20260717_042127_531": "stealth",
    "20260717_042242_389": "combat",
    "20260717_042331_520": "mounted",
}

# flag base -> the stamp field that INDEPENDENTLY witnesses the same state.
# This is a JOIN definition, and it is the load-bearing judgement in this file, so it is
# explicit rather than clever. `api` cites wowpedia's own "Similar API" column where it
# had one (reference/candidates.json -> claimed_by[].says).
# `expect_true_when` is read against the stamp; a conditional reading TRUE while its
# witness says FALSE is the contradiction that proves it is ignored.
WITNESS = {
    "combat":      ("inCombat",       "UnitAffectingCombat()"),
    "mounted":     ("mounted",        "IsMounted()"),
    "stealth":     ("stealthed",      "IsStealthed()"),
    "flying":      ("flying",         "IsFlying()"),
    "flyable":     ("flyableArea",    "IsFlyableArea()"),
    "swimming":    ("swimming",       "IsSwimming()"),
    "indoors":     ("indoors",        "IsIndoors()"),
    "outdoors":    ("outdoors",       "IsOutdoors()"),
    "resting":     ("resting",        "IsResting()"),
    "exists":      ("hasTarget",      "UnitExists()"),
    "harm":        ("targetHarm",     "UnitCanAttack()"),
    "help":        ("targetHelp",     "UnitCanAssist()"),
    "dead":        ("targetIsDead",   "UnitIsDeadOrGhost()"),
    "vehicleui":   ("hasVehicleBar",  "HasVehicleActionBar()"),
    "unithasvehicleui": ("inVehicle", "UnitInVehicle()"),
    "canexitvehicle":   ("inVehicle", "CanExitVehicle() - cannot exit a vehicle you are not in"),
    "mod":         ("_anyModifier",   "IsShiftKeyDown()/IsControlKeyDown()/IsAltKeyDown()"),
    "modifier":    ("_anyModifier",   "IsShiftKeyDown()/IsControlKeyDown()/IsAltKeyDown()"),
    "party":       ("inParty",        "UnitInParty()"),
    "raid":        ("inRaid",         "UnitInRaid()"),
    "pet":         ("hasPet",         "UnitExists('pet')"),
    "cursor":      ("cursorHolding",  "GetCursorInfo()"),
}

CENSUS = ROOT / "addons" / "maps" / "census" / "runtime" / "globals.json"


def mirrored_apis():
    """The wiki names the API each conditional MIRRORS; the census says whether that API
    exists on THIS client. Both ends sourced, joined mechanically - no hand-listing.

    wowpedia's Boolean tables carry a "Similar API" column, captured verbatim into
    reference/candidates.json -> claimed_by[].says as "(similar API: api|HasExtraActionBar())".

    WHY THIS IS THE DISCRIMINATOR the polarity pair could not be: a conditional whose whole
    SUBSYSTEM is absent from the client, reading constant-TRUE under proven ignore-semantics,
    is being ignored. It replaces prose reasoning ("pet battles are MoP") with a census fact
    (C_PetBattles is not resident).

    HONEST LIMIT: an absent Lua API does not PROVE the C parser lacks the conditional. It
    proves the subsystem is absent. Combined with (a) unknown => ignored, PROVEN, and (b) a
    constant-TRUE read, it is strong - but it is INFERENCE FROM TWO MECHANICAL FACTS, not a
    direct observation. Confidence is stated as such, and where the API IS present the
    verdict stays AMBIGUOUS rather than being talked into place.
    """
    if not (REF.is_file() and CENSUS.is_file()):
        return {}, {}
    reg = json.load(open(REF, encoding="utf-8"))["candidates"]
    f = json.load(open(CENSUS, encoding="utf-8"))["functions"]
    live = {n: b for b, names in f.items() for n in names}
    out = {}
    for tok, e in reg.items():
        for c in e.get("claimed_by", []):
            for api in re.findall(r"api\|(\w+)", c.get("says") or ""):
                out.setdefault(tok, {})[api] = live.get(api)  # None == not resident
    return out, live


def truthy(v):
    """This client returns 1/nil, NOT true/false (Battlewrath + the addons bench, 2026-07-17).
    JSON null on a stamp field means FALSEY, not unread - Lua drops nil keys on encode."""
    return v is not None and v is not False and v != 0


def sig(entry):
    """RAW pair -> the shape. pos/neg absent == nil == the clause did not pass."""
    p = truthy(entry.get("pos"))
    n = truthy(entry.get("neg"))
    return "T" if (p and not n) else "F" if (n and not p) else "BOTH" if (p and n) else "NEITHER"


def load():
    recs = {}
    for f in sorted(RECORDS.glob("*__macros.json")):
        d = json.load(open(f, encoding="utf-8"))
        rid = d["header"]["runId"]
        if rid not in CONTEXTS:
            continue
        recs[CONTEXTS[rid]] = {
            "runId": rid, "record": d["payload"]["record"],
            "harness_sha256": d["payload"]["harness"]["sha256"],
            "class": d["header"].get("class"), "file": f.name,
        }
    return recs


def stamp_value(ctx, field):
    c = ctx["record"]["context"]
    if field == "_anyModifier":
        return any(truthy(c.get(k)) for k in ("shiftDown", "ctrlDown", "altDown"))
    return truthy(c.get(field))


def derive_flags(recs, apis):
    order = [k for k in ("rest", "spell-form", "stealth", "combat", "mounted") if k in recs]
    flags = sorted(recs[order[0]]["record"]["flags"])
    # base -> its arg-siblings, so a false sibling can prove the BASE is evaluated
    fam = {}
    for f in flags:
        fam.setdefault(f.split(":")[0], []).append(f)

    out = {}
    for f in flags:
        row = {c: sig(recs[c]["record"]["flags"][f]) for c in order}
        vals = set(row.values())
        base = f.split(":")[0]
        arg = f.split(":", 1)[1] if ":" in f else None

        reads_false = "F" in vals
        varies = len(vals) > 1
        sibling_false = any("F" in {sig(recs[c]["record"]["flags"][s]) for c in order}
                            for s in fam[base] if s != f)

        wit, api = WITNESS.get(base, (None, None))
        mirrored = apis.get(f) or apis.get(base) or {}
        wit_row = {c: stamp_value(recs[c], wit) for c in order} if wit else None
        contradiction = None
        if wit_row and not varies and vals == {"T"} and not any(wit_row.values()):
            contradiction = (f"reads TRUE in every context while its independent witness "
                             f"`{wit}` ({api}) is FALSE in every context")

        # ---- the derivation (see the module docstring; order matters)
        if varies:
            verdict, why, conf = ("SUPPORTED-PROVEN",
                                  "varies across contexts - it tracked real state", "high")
        elif reads_false:
            verdict, why, conf = ("SUPPORTED",
                                  "reads FALSE somewhere - an ignored clause can never read "
                                  "false, so the parser evaluated it", "high")
        elif contradiction:
            verdict, why, conf = ("UNSUPPORTED-IGNORED", contradiction, "high")
        elif vals == {"T"} and mirrored and not any(mirrored.values()):
            verdict, why, conf = (
                "UNSUPPORTED-IGNORED",
                f"reads TRUE in every context, and the API it mirrors is NOT RESIDENT on "
                f"this client (census): {', '.join(sorted(mirrored))}. The whole subsystem "
                f"is absent, so there is nothing to evaluate - and unknown => ignored is "
                f"PROVEN. Inference from two mechanical facts, not a direct observation.",
                "high-inferred")
        elif sibling_false:
            verdict, why, conf = ("SUPPORTED-TRUE",
                                  f"constant TRUE, but an arg-sibling of `{base}` reads FALSE "
                                  f"- the base IS evaluated, so this arg is genuinely true",
                                  "high")
        elif wit_row and all(wit_row.values()):
            verdict, why, conf = ("SUPPORTED-TRUE",
                                  f"constant TRUE and its witness `{wit}` ({api}) is TRUE in "
                                  f"every context - corroborated", "medium")
        else:
            verdict, why, conf = ("AMBIGUOUS",
                                  "constant TRUE with no witness and no false sibling. On "
                                  "this parser an ignored clause is indistinguishable from a "
                                  "true one - NOT guessing", "none")

        out[f] = {"flag": f, "base": base, "arg": arg, "verdict": verdict, "why": why,
                  "confidence": conf, "by_context": row,
                  "witness_field": wit, "witness_api": api,
                  "witness_by_context": wit_row,
                  "mirrored_api_resident": mirrored or None}
    return out, order


def derive_targets(recs, order):
    tgts = sorted(recs[order[0]]["record"]["targets"])
    control = {c: recs[c]["record"]["control"] for c in order}
    passthrough = all(v.get("target") == "banana" for v in control.values())
    out = {}
    for t in tgts:
        rows = {c: recs[c]["record"]["targets"][t] for c in order}
        parsed = {c: r.get("target") for c, r in rows.items()}
        exists = {c: truthy(r.get("unit_exists")) for c, r in rows.items()}
        names = {c: r.get("unit_name") for c, r in rows.items()}
        probe = rows[order[0]].get("unit_probe")
        if not probe:
            verdict, why = ("NOT-A-UNIT",
                            "no unit probe - this token is not a unit token at all "
                            "(cursor: absent from every unit-token list on both wikis; it is "
                            "a macro-layer special case, hand-rolled here via "
                            "Custom_HandleTerrainClick)")
        elif any(exists.values()):
            verdict, why = ("RESOLVES",
                            f"UnitExists('{probe}') true in: "
                            f"{[c for c in order if exists[c]]}")
        else:
            verdict, why = ("DID-NOT-RESOLVE-HERE",
                            f"UnitExists('{probe}') false in all five contexts. NOT proof of "
                            f"absence - context-bound (no party/raid/arena/boss present). "
                            f"Unproven, not unsupported")
        out[t] = {"token": t, "unit_probe": probe, "verdict": verdict, "why": why,
                  "parser_returned": parsed, "unit_exists_by_context": exists,
                  "unit_name_by_context": {k: v for k, v in names.items() if v}}
    return out, passthrough, control


def era_test(flags):
    """The forecast test. operations/Macros.md stated these expectations BEFORE the capture,
    precisely so the result could contradict them instead of quietly confirming them.

    The era signal is derived from the wikis' {{Patch}} annotations (evidence), never from a
    wiki's silence (which is not evidence - that error was made once and corrected)."""
    from collections import Counter, defaultdict
    reg = json.load(open(REF, encoding="utf-8"))["candidates"]
    tab = defaultdict(Counter)
    for k, v in flags.items():
        era = reg.get(v["base"], {}).get("era_signal", "(not in register)")
        fam = "SUPPORTED" if v["verdict"].startswith("SUPPORTED") else v["verdict"]
        tab[era][fam] += 1
    arch = tab.get("archive-documented", Counter())
    post = Counter()
    for e in ("patch-dated", "retail-documented-only"):
        post.update(tab.get(e, Counter()))
    return {
        "what": "era signal (predicted from patch annotations BEFORE the capture) vs the "
                "live verdict",
        "by_era": {k: dict(v) for k, v in tab.items()},
        "forecast_said_archive_documented": "expected present on a 3.3.5a base; an "
                                            "UNSUPPORTED here would be a real finding",
        "result_archive_documented": dict(arch),
        "forecast_said_post_3_3_5a": "the live question - this client backports freely, so "
                                     "absence is NOT predictable either way",
        "result_post_3_3_5a": dict(post),
        "VERDICT": ("TOTAL SEPARATION, ZERO CROSSOVER. Every archive-documented (WotLK-era) "
                    f"conditional is SUPPORTED ({arch.get('SUPPORTED', 0)}/"
                    f"{sum(arch.values())}). NOT ONE post-3.3.5a conditional is "
                    f"({post.get('SUPPORTED', 0)}/{sum(post.values())}). The era diff "
                    "predicted the live verdict exactly."
                    if arch.get("UNSUPPORTED-IGNORED", 0) == 0 and post.get("SUPPORTED", 0) == 0
                    else "MIXED - read by_era; the era signal did not cleanly predict."),
        "what_this_validates": "the method, not the luck: patch annotations are EVIDENCE and "
                               "they forecast the client. It also retires the reverse error - "
                               "inferring era from a wiki's ABSENCE - which predicted the same "
                               "4 rows for the wrong reason.",
    }


def main():
    recs = load()
    if len(recs) < 5:
        print(f"STOP: expected 5 context records, found {len(recs)}: {sorted(recs)}")
        sys.exit(2)
    apis, _live = mirrored_apis()
    flags, order = derive_flags(recs, apis)
    targets, passthrough, control = derive_targets(recs, order)

    from collections import Counter
    fc = Counter(v["verdict"] for v in flags.values())
    tc = Counter(v["verdict"] for v in targets.values())

    payload = {
        "what": "THE VERDICT MAP - derived OFFLINE from the landed raw captures. Nothing "
                "here was decided in-game.",
        "derived_by": "macros/tools/derive_verdicts.py",
        "grain": "LIVE-PROVEN, five contexts, triangulated against an independent witness "
                 "stamp. Per-verdict confidence is stated; AMBIGUOUS is a real answer.",
        "evidence": {
            "records": {c: {"runId": r["runId"], "file": r["file"]} for c, r in recs.items()},
            "labels_from": "addons/landing/records/20260717_contexts.md (Battlewrath, live)",
            "character_class": recs[order[0]]["class"],
            "harness_sha256": recs[order[0]]["harness_sha256"],
            "harness_note": "matches macros/probe/probe_core.lua at HEAD (LF-normalised; the "
                            "working copy is CRLF, hence a different raw digest)",
        },
        "PARSER_SEMANTICS_THE_HEADLINE": {
            "finding": "An UNKNOWN conditional is IGNORED and the clause PASSES. It is not "
                       "rejected.",
            "therefore": "[unknown] = 'Y' and [nounknown] = nil - IDENTICAL to a known-true "
                         "conditional. The polarity pair CANNOT distinguish unsupported from "
                         "currently-true.",
            "the_designed_matrix_was_WRONG": "probe/README and the old conditionals.json "
                                             "shipped 'X=false, noX=false => UNSUPPORTED'. "
                                             "That row NEVER OCCURS: across 5 contexts x "
                                             f"{len(flags)} flags there is not one both-nil.",
            "proof": [
                "[petbattle] reads TRUE in all five contexts - pet battles are MoP 5.0; a "
                "3.3.5a client has no pet battle system and none was running.",
                "[resting] reads TRUE in all five while the stamp's IsResting() is FALSEY in "
                "all five - a direct contradiction with an independent witness.",
            ],
            "what_saved_the_pass": "the CONTEXT STAMP and FIVE contexts. Without them this "
                                   "capture would have reported ~10 retail-only conditionals "
                                   "as PROVEN-TRUE and graduated them into the basis as "
                                   "fact. The stamp is the only reason the map is not "
                                   "confidently wrong.",
            "the_rule_that_replaces_it": "reads FALSE anywhere => EVALUATED => SUPPORTED. An "
                                         "ignored clause can never read false.",
            "and_for_constant_TRUE": "the wiki names the API each conditional MIRRORS "
                                     "('Similar API'); the census says whether that API is "
                                     "resident HERE. Subsystem absent + constant TRUE + "
                                     "ignore-semantics => ignored. Both ends sourced, joined "
                                     "mechanically. Where the API IS resident the verdict "
                                     "stays AMBIGUOUS rather than being talked into place.",
        },
        "at_targets": {
            "control_row_SETTLED": passthrough,
            "finding": "[@banana] returned target='banana' in ALL FIVE contexts => `@` is a "
                       "PASS-THROUGH STRING. The parser does not validate units; it hands the "
                       "string on. Support lives DOWNSTREAM (the handler's special-casing + "
                       "unit resolution).",
            "therefore": "the polarity matrix never applied to targets, and there is no "
                         "[no@cursor]. The target question is UnitExists, not the parser.",
            "control_by_context": {c: v.get("target") for c, v in control.items()},
        },
        "THE_FORECAST_TEST": era_test(flags),
        "THE_LAYER_FINDING": {
            "finding": "ASCENSION EXTENDS AT THE LUA/HANDLER LAYER, NOT THE C PARSER.",
            "evidence": [
                "ZERO post-3.3.5a CONDITIONALS are supported (0 of 10) - the C conditional "
                "parser is untouched stock 3.3.5a.",
                "YET @cursor - a LEGION 7.1.0 feature, Blizzard-cited - IS present, "
                "hand-rolled in ChatFrame.lua's /cast handler via Custom_HandleTerrainClick "
                "(and on /castsequence and /castrandom too).",
                "Every Ascension macro extension found in source is Lua: the 27 inline "
                "SLASH_ commands, /kb -> ToggleQuickKeybindMode (a Dragonflight backport), "
                "the terrain-click hack.",
            ],
            "why_it_matters": "it predicts where a future CoA macro capability CAN come from "
                              "(a handler) and where it CANNOT (the conditional vocabulary), "
                              "and it explains the perfect era separation: the parser is "
                              "stock, so it knows exactly the stock 3.3.5a vocabulary and "
                              "ignores everything newer.",
            "status": "STRONGLY SUPPORTED by the capture; it was a HYPOTHESIS before it "
                      "(raised 2026-07-17 from the source reads, untestable without the "
                      "client). Not a proof of the C binary's contents - a coherent account "
                      "of every observation we have.",
        },
        "counts": {"flags": dict(fc), "targets": dict(tc)},
        "flags": flags,
        "targets": targets,
        "KNOWN_GAPS": {
            "no_flag_control_row": "The ask has [@banana] as a TARGET control but NO flag "
                                   "control (e.g. [zzznotaconditional]). The unknown=>ignored "
                                   "semantics had to be inferred from petbattle/advflyable/"
                                   "resting acting as de-facto controls. A designed control "
                                   "row would have made it immediate. ADD ON ANY RE-RUN.",
            "macro_limits_unread": "maxAccountMacros/maxCharacterMacros/maxMacros_legacy all "
                                   "came back nil - Blizzard_MacroUI is LOAD-ON-DEMAND "
                                   "(MacroFrame_LoadUI), so those globals do not exist until "
                                   "the macro window has been opened. The 36-vs-18 conflict "
                                   "is NOT resolved. It also re-reads Asc_MacroBank's "
                                   "`MAX_CHARACTER_MACROS or 18` as a LOAD-ORDER guard, not "
                                   "a version guard - which is how I first read it. "
                                   "GetNumMacros() works (C API, always resident): 4 account "
                                   "/ 0 character.",
            "bonusbar_arg_gap": "the stamp shows bonusBarOffset=1 in STEALTH, so "
                                "[bonusbar:1] should be true - but the ask only carries "
                                "[bonusbar:5] (the only value the wiki documented). The arg "
                                "list is only as wide as the source's examples.",
            "placeholder_arg_leaked": "[form:n] / [stance:n] were asked - `n` is a "
                                      "PLACEHOLDER from the wiki's 'form:0/.../n', not a real "
                                      "arg. It reads identically to form:0, which is itself "
                                      "informative about arg parsing, but it was not a "
                                      "deliberate question.",
            "ambiguous_is_honest": "constant-TRUE flags with no witness and no false sibling "
                                   "stay AMBIGUOUS. On this parser that is the truthful "
                                   "answer, not a failure to try.",
        },
    }
    with open(BASIS / "conditionals.json", "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=1, ensure_ascii=False)
        f.write("\n")

    # ---- write the verdicts BACK onto the register's proof_marks. This is the loop the
    # whole design exists to close: reference/ poses the question, the client answers, the
    # map adjudicates, and ONLY the proven set graduates. reference/ never becomes basis/
    # by itself - it gets STAMPED by evidence.
    reg = json.load(open(REF, encoding="utf-8"))
    stamped = 0
    for tok, e in reg["candidates"].items():
        v = flags.get(tok) or flags.get(tok.lstrip("@"))
        t = targets.get(tok) or targets.get("@" + tok)
        if v and e["kind"] == "flag":
            e["proof_mark"] = f"LIVE:{v['verdict']}"
            e["live_verdict"] = {"verdict": v["verdict"], "confidence": v["confidence"],
                                 "why": v["why"], "by_context": v["by_context"],
                                 "derived_by": "macros/tools/derive_verdicts.py",
                                 "from": "the 5-context capture, 2026-07-17"}
            stamped += 1
        elif t and e["kind"] == "unit-target":
            e["proof_mark"] = f"LIVE:{t['verdict']}"
            e["live_verdict"] = {"verdict": t["verdict"], "why": t["why"],
                                 "parser_returned": t["parser_returned"],
                                 "derived_by": "macros/tools/derive_verdicts.py",
                                 "from": "the 5-context capture, 2026-07-17"}
            stamped += 1
    reg["proof_marks"] = dict(reg.get("proof_marks", {}), **{
        "LIVE:SUPPORTED-PROVEN": "the capture: varies across contexts - it tracked real state",
        "LIVE:SUPPORTED": "the capture: reads FALSE somewhere, so the parser evaluated it",
        "LIVE:SUPPORTED-TRUE": "the capture: constant true, corroborated by a witness or a "
                               "false arg-sibling",
        "LIVE:UNSUPPORTED-IGNORED": "the capture: the parser IGNORES it (clause passes). "
                                    "Proven by a witness contradiction or an absent subsystem.",
        "LIVE:AMBIGUOUS": "the capture could not decide, and the map does NOT guess. On this "
                          "parser an ignored clause is indistinguishable from a true one.",
        "LIVE:RESOLVES": "the capture: UnitExists() true for this token",
        "LIVE:DID-NOT-RESOLVE-HERE": "the capture: no unit in these 5 contexts. NOT absence - "
                                     "context-bound. Unproven, not unsupported.",
        "LIVE:NOT-A-UNIT": "not a unit token at all (cursor: a macro-layer special case)",
    })
    reg["live_capture"] = {
        "landed": "2026-07-17, 5 contexts (addons bench harness, Battlewrath live)",
        "records": [r["file"] for r in recs.values()],
        "map": "macros/tools/derive_verdicts.py -> macros/basis/conditionals.json",
        "note": "proof_marks prefixed LIVE: are the client's answer. Everything else is "
                "still a question.",
    }
    with open(REF, "w", encoding="utf-8") as f:
        json.dump(reg, f, indent=1, ensure_ascii=False)
        f.write("\n")
    print(f"proof_marks stamped back onto the register: {stamped}")

    print(f"flags   : {dict(fc)}")
    print(f"targets : {dict(tc)}")
    print(f"control : @ pass-through = {passthrough}")
    return payload


if __name__ == "__main__":
    main()
