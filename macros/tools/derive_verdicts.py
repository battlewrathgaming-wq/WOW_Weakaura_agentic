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

# A conditional whose SUBSYSTEM the wiki names, but whose API surface the census cannot find.
# Same shape as the mirrored-API join, for the cases where the wiki gave a DESCRIPTION but no
# "Similar API" column - so the mechanical join had nothing to bite on and the flag fell
# through to AMBIGUOUS.
#
# EXPLICIT and JUSTIFIED, like WITNESS: each entry cites the wiki's own definition and the
# API pattern that WOULD evidence the subsystem. The census answers; this table only asks.
#
# pvpcombat was the last AMBIGUOUS flag. Battlewrath, 2026-07-17, supplied the missing link:
# "there is instanced PVP, Duels, and then also engaging an enemy player. But the game doesn't
# have PVP talents. That was a later itteration of WoW." Taken as the QUESTION, not the fact -
# the census then proves it: ZERO PvpTalent APIs resident, while UnitIsPVP /
# UnitIsPVPFreeForAll / GetBattlefieldStatus / StartDuel / GetZonePVPInfo ARE. The PVP STATES
# are real; the PVP TALENT system is not.
SUBSYSTEM_PROBE = {
    "pvpcombat": (r"PvpTalent|PVPTalent|PvPTalent",
                  "the wiki defines it as 'PvP talents are usable' and dates it 7.3.0 "
                  "(Legion). PvP TALENTS are a Legion system - distinct from PVP itself, "
                  "which this client has in full (instanced, duels, flagged combat: "
                  "UnitIsPVP / GetBattlefieldStatus / StartDuel all resident). If no "
                  "PvP-talent API exists, the conditional names a system that is not here."),
}


# Convictions from the CHAT PROBE tier - weaker provenance (hand-transcribed), but real
# evidence. The landed capture could not decide these; the chat probe asked the API and the
# conditional SIDE BY SIDE and got a contradiction - the same conviction that got [resting].
#
# Applied AFTER the landed-capture rules, and the verdict SAYS WHICH TIER decided it. Leaving
# a flag AMBIGUOUS when evidence exists would be under-reporting; merging it silently into the
# capture's verdicts would launder hand-typed output into machine-grade provenance. Neither.
CHAT_CONVICTIONS = {
    "overridebar": "chat probe 2026-07-17: HasOverrideActionBar() returned nil while "
                   "[overridebar] returned Y - the same contradiction that convicted "
                   "[resting]. The API is resident, so the capture alone could not rule it "
                   "out; asking the API and the conditional side by side did.",
    "possessbar": "chat probe 2026-07-17: IsPossessBarVisible() returned false while "
                  "[possessbar] returned Y - contradiction.",
    "known": "chat probe 2026-07-17: [known:1] returned Y for a spell the character does not "
             "have. (IsPlayerSpell is absent from the census; GetSpellInfo is resident, which "
             "is why the mirrored-API join could not rule it out.)",
}


def subsystem_absent(base, live):
    pat, why = SUBSYSTEM_PROBE.get(base, (None, None))
    if not pat:
        return None
    found = sorted(n for n in live if re.search(pat, n))
    return {"pattern": pat, "why": why, "apis_found": found, "absent": not found}


# ---------------------------------------------------------------- the chat probe tier
#
# A SEPARATE, WEAKER EVIDENCE TIER than the landed capture. Kept separate on purpose:
#   landed capture : runId + sha256 + harness sha + _provenance, pulled by the watcher.
#   chat probe     : hand-transcribed from chat by a human. No runId, no sha, no record -
#                    and there was already one transcription typo, self-corrected.
# Merging them would launder hand-typed output into machine-grade provenance. It does not
# get merged; it gets cited, and where it CONVICTS a flag the reason says which tier did it.
#
# Battlewrath, 2026-07-17, unprompted and load-bearing: "I was in PVP for that. So the flags
# might be all over the place." He is right, and it cost exactly one row - see A below.
CHAT_PROBE = {
    "tier": "CHAT PROBE - live, but hand-transcribed. WEAKER than the landed capture.",
    "when": "2026-07-17, immediately after the 5-context capture",
    "context_caveat": "Battlewrath was IN PVP (and therefore IN COMBAT) when these ran, and "
                      "flagged it himself. That confound killed probe A's REFERENCE row and "
                      "nothing else - see per-probe notes.",
    "A_flag_control": {
        "asked": '[zzz] / [nozzz] / [resting] / [noresting] / [combat] / [nocombat]',
        "returned": "zzz Y/nil · resting Y/nil · combat Y/nil",
        "the_reference_row_DIED": "[combat] was chosen as the 'supported but currently FALSE' "
                                  "reference. He was in combat, so it read TRUE - identical to "
                                  "zzz and resting. The comparison proves nothing. My probe "
                                  "design assumed a rest context and did not say so.",
        "but_the_ACTUAL_FINDING_STANDS": "[zzz] is NONSENSE and returned Y; [nozzz] returned "
                                         "nil. That is DIRECT OBSERVATION that an unknown "
                                         "token evaluates TRUE and the no- prefix negates it. "
                                         "It no longer rests on petbattle/resting as de-facto "
                                         "controls. The probe delivered its real job despite "
                                         "the confound.",
    },
    "D_ambiguity_resolver": {
        "asked": "HasOverrideActionBar() vs [overridebar] · IsPossessBarVisible() vs "
                 "[possessbar] · [known:1] (a spell he certainly does not have)",
        "returned": "OB: API=nil, [overridebar]=Y · PB: API=false, [possessbar]=Y · "
                    "[known:1]=Y",
        "verdict": "THREE CONTRADICTIONS - the same conviction that got [resting]. All three "
                   "are IGNORED. PVP does not touch vehicle/possess state, so the confound "
                   "does not reach these.",
        "resolves": ["overridebar", "possessbar", "known"],
    },
    "B_macro_limits_RESOLVED": {
        "asked": "MacroFrame_LoadUI() then MAX_ACCOUNT_MACROS / MAX_CHARACTER_MACROS / "
                 "MAX_MACROS / GetNumMacros()",
        "returned": "acct=36 · char=36 · legacy=nil · GetNumMacros()=4,0",
        "verdict": "THE CONFLICT IS RESOLVED. MAX_CHARACTER_MACROS = 36, NOT 18. "
                   "MacroFrame_LoadUI() was the missing step - exactly as the "
                   "load-on-demand reading predicted (the globals do not exist until the "
                   "macro window loads, which is why the capture's stamp read nil, and why "
                   "Asc_MacroBank carries `or 18` as a LOAD-ORDER guard).",
        "the_client_bug_this_evidences": "QuickKeybindActionPicker declares a LOCAL "
                                         "MAX_CHARACTER_MACROS=18 (the stock WotLK value) "
                                         "that shadows the global 36 inside that file. The "
                                         "global is 36 LIVE => the backported keybind picker "
                                         "very likely CANNOT SEE character macros 19-36. A "
                                         "real bug in THEIR client, now evidenced rather "
                                         "than hypothesised. Not ours to fix; worth telling.",
        "unaffected_by_the_pvp_confound": True,
    },
    "C_bonusbar": {
        "asked": "GetBonusBarOffset() · [bonusbar:1] · [bonusbar:5] · [bar:1]",
        "returned": "offset=1 · [bonusbar:1]=Y · [bonusbar:5]=nil · [bar:1]=Y",
        "verdict": "bonusbar is SUPPORTED and TRACKING: offset=1 corroborates [bonusbar:1]=Y, "
                   "and [bonusbar:5]=nil proves it is evaluated. The arg the ask never "
                   "carried, now answered. Corroboration holds regardless of WHY the offset "
                   "is 1, so the pvp confound does not reach it.",
    },
    "STILL_AMBIGUOUS_and_honest": {
        "pvpcombat": "survives D. The wiki says it means 'PvP talents are usable' (a Legion+ "
                     "system), NOT 'in pvp combat' - so being in PVP does NOT witness it, and "
                     "IsPVPTalentUsable is absent from the census. No witness => no verdict. "
                     "Not guessing.",
    },
    "what_I_got_wrong_in_the_ask": "probe A silently assumed a REST context for its reference "
                                   "row and never said so. A control row needs its required "
                                   "context stated, or the human cannot know they are "
                                   "invalidating it. He caught it; the probe should have.",
}


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


def derive_flags(recs, apis, live):
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
        subsys = subsystem_absent(base, live)
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
        elif vals == {"T"} and subsys and subsys["absent"]:
            verdict, why, conf = (
                "UNSUPPORTED-IGNORED",
                f"reads TRUE in every context, and the SUBSYSTEM it names is absent from this "
                f"client (census: no API matching /{subsys['pattern']}/). {subsys['why']} "
                f"Under proven ignore-semantics, a conditional naming a system that is not "
                f"here and reading constant-TRUE is being ignored.",
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
        elif vals == {"T"} and base in CHAT_CONVICTIONS:
            verdict, why, conf = ("UNSUPPORTED-IGNORED", CHAT_CONVICTIONS[base],
                                  "medium-CHAT-PROBE-TIER (hand-transcribed, not a landed "
                                  "record - weaker provenance than the 5-context capture)")
        else:
            verdict, why, conf = ("AMBIGUOUS",
                                  "constant TRUE with no witness and no false sibling. On "
                                  "this parser an ignored clause is indistinguishable from a "
                                  "true one - NOT guessing", "none")

        out[f] = {"flag": f, "base": base, "arg": arg, "verdict": verdict, "why": why,
                  "confidence": conf, "by_context": row,
                  "witness_field": wit, "witness_api": api,
                  "witness_by_context": wit_row,
                  "mirrored_api_resident": mirrored or None,
                  "subsystem_probe": subsys}
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
    apis, live = mirrored_apis()
    flags, order = derive_flags(recs, apis, live)
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
        "WHAT_THE_PARSER_ACTUALLY_IS": {
            "framing": "Battlewrath, 2026-07-17: 'So it sounds more like an adaptor than true "
                       "conditional logic?' — the data says yes.",
            "it_is": [
                "a KEYWORD MATCHER over a FIXED vocabulary of flattened state reads "
                "(UnitAffectingCombat, IsMounted, IsStealthed, GetShapeshiftForm...)",
                "a CLAUSE SELECTOR - first clause whose tests all pass wins",
                "an ARGUMENT ADAPTOR - macro text in, (action, target) out, handed to a "
                "handler which does the actual work",
            ],
            "it_is_NOT": [
                "conditional LOGIC - logic validates its terms; this does not",
                "a validator - unknown tokens do not error, do not reject, do not skip",
                "extensible - the vocabulary is fixed in C, which is exactly WHY Ascension "
                "added [@cursor] in the HANDLER (Custom_HandleTerrainClick) rather than the "
                "parser. The framing explains the layer finding rather than coexisting with it.",
            ],
            "the_decisive_evidence": {
                "[outdoors]": "pos=Y, neg=nil - REAL, and genuinely true (stamp outdoors=1)",
                "[petbattle]": "pos=Y, neg=nil - a system that DOES NOT EXIST on this client",
                "reading": "byte-identical. And the no- prefix IS processed: it negates "
                           "whatever the lookup yielded, so unknown evaluates TRUE and its "
                           "negation returns false.",
            },
            "same_shape_as_WA": "neither holds state - the game does. WA flattens native "
                                "signals into trigger fields; the macro parser flattens the "
                                "same signals into keywords. Both are read-and-flatten "
                                "surfaces. Neither reasons. (memory: "
                                "wa-reads-and-flattens-native-state)",
        },
        "THE_FOOTGUN_THE_GUIDE_MUST_LEAD_WITH": {
            "rule": "AN UNSUPPORTED CONDITIONAL SILENTLY SUCCEEDS. It does not error.",
            "worked_example": "/cast [resting] Drink; Frostbolt  ->  ALWAYS Drink, never "
                              "Frostbolt. [resting] is PROVEN unsupported here (witness "
                              "contradiction, all 5 contexts), so it evaluates TRUE, the "
                              "first clause always wins, and the fallback chain COLLAPSES to "
                              "its first element.",
            "why_it_is_worse_than_an_error": "the macro appears to work. No error, no "
                                             "warning, no indication. A player copying a "
                                             "retail fallback chain into CoA gets something "
                                             "that fires confidently and wrongly - "
                                             "plausible, silent, and indistinguishable from "
                                             "correct.",
            "who_this_hits": "anyone following a retail macro guide - which is nearly every "
                             "macro guide, including the Ascension wiki's own, since it "
                             "inherits its conditional list from the retail wikis (see "
                             "reference/README).",
            "the_defence": "the 6 UNSUPPORTED-IGNORED + 4 AMBIGUOUS in `flags` below are the "
                           "list to never put in a macro on this client. Everything "
                           "archive-documented is safe (53/53 supported).",
        },
        "GRAMMAR_PROVEN_2026_07_17": {
            "tier": "CHAT PROBE (hand-transcribed) - but each finding has MULTIPLE "
                    "independent confirmations, and each probe carried its own witness. "
                    "Stronger than the vocabulary's weakest rows.",
            "why_this_mattered": "the walk showed the basis proved every TERM of a real macro "
                                 "and not one CONNECTIVE. 14 grammar claims sat in reference/, "
                                 "all UNPROVEN, none ever asked. A macro is mostly SENTENCE. "
                                 "This is the sentence.",
            "comma_is_AND": {
                "verdict": "PROVEN. `,` conjoins within a clause.",
                "evidence": [
                    "[combat,nocombat] = FAIL in BOTH runs. If `,` were OR it would have "
                    "passed (nocombat was true, cb=nil). Context-free by construction: one "
                    "term is always true and the other always false, whichever state you are "
                    "in.",
                    "and independently in probe F: [@mouseover] = Y but [@mouseover,harm] = "
                    "FAIL. The comma conjoins a TARGET with a FLAG, and harm being false "
                    "killed the clause even though the target was fine.",
                ],
            },
            "semicolon_is_FIRST_TRUE_WINS": {
                "verdict": "PROVEN. `;` separates alternative clauses; the first whose tests "
                           "all pass wins.",
                "evidence": "cb=nil (NOT in combat) -> [combat]A;[nocombat]B returned B. "
                            "First clause false => skipped; second true => won. BOTH runs.",
                "the_witness_is_the_point": "cb travelled IN the probe. Without it, B is "
                                            "unreadable - it could mean last-true, or "
                                            "right-to-left. Carrying the witness is the fix "
                                            "for what killed probe A's control row.",
            },
            "slash_is_OR_within_an_arg": {
                "verdict": "PROVEN. `/` is OR over an argument list.",
                "evidence": "frm=1: [stance:0/1]=Y AND [stance:1/2]=Y - both true, NO "
                            "discrimination. frm=0: [stance:0/1]=Y but [stance:1/2]=FAIL - "
                            "0 is in {0,1} and not in {1,2}. Exactly OR.",
                "it_took_BOTH_runs": "run 1 alone was ambiguous (form 1 sits in both sets). "
                                     "Battlewrath toggling the form off produced the "
                                     "contrast. A single context could not have proven this - "
                                     "the same lesson as the 5-context capture, in miniature.",
            },
            "at_mouseover_RESOLVES": {
                "verdict": "PROVEN. Closes the last target hole.",
                "evidence": "UnitName('mouseover')='Scarletta', UnitExists=1, [@mouseover]=Y, "
                            "[@mouseover,help]=Y, [@mouseover,harm]=FAIL - friendly to "
                            "yourself, not hostile. Triangulated against a known answer.",
                "the_blind_spot_I_claimed_was_WRONG": "I wrote that mouseover may be "
                                                      "structurally unprobeable from chat "
                                                      "because typing means the mouse left "
                                                      "the unit. Battlewrath: 'I can hit "
                                                      "enter, ctrl v, and mouse over myself "
                                                      "at the same time.' Correct - I "
                                                      "conflated TYPING time with EXECUTION "
                                                      "time. Paste with the keyboard, move "
                                                      "the mouse onto the unit, THEN press "
                                                      "Enter. The mouse only has to be there "
                                                      "when Enter fires, and Enter is a "
                                                      "keypress. The channel has no such "
                                                      "blind spot.",
            },
            "HYPOTHESIS_not_fact": {
                "failed_parse_returns_NO_VALUES": "run 1 printed 'OR Y Y nil' (p2 returned "
                                                  "action+target) while run 2 printed 'OR Y' "
                                                  "(p2 appears to have returned NOTHING, not "
                                                  "nil - a nil would have printed). Suggests "
                                                  "SecureCmdOptionParse returns zero values on "
                                                  "no-match. ONE datum, HAND-TRANSCRIBED - "
                                                  "he may simply not have typed trailing nils "
                                                  "(though he DID type one in run 1). Marked "
                                                  "hypothesis. Functionally identical either "
                                                  "way (`local a,b = f()` gives nil,nil).",
            },
            "NOTED_not_concluded": {
                "two_kinds_of_form": "Battlewrath: 'Should be in a form, but maybe the weird "
                                     "spell-form thing again.' It was NOT: frm=1, so THIS "
                                     "form IS visible to GetShapeshiftForm - unlike the "
                                     "capture's spell-form, which read 0 while he was "
                                     "demonstrably in one (the label/stamp disagreement the "
                                     "addons bench flagged). So there are at least TWO kinds "
                                     "of form on this client: stance-visible and "
                                     "buff-invisible. Not chased here.",
                "different_character": "F returned 'Scarletta'; the 5-context capture's "
                                       "@player was 'Gravereaper' (class REAPER). These "
                                       "probes ran on a DIFFERENT character. Grammar is "
                                       "character-independent (the parser is the parser), so "
                                       "the findings stand - but form/stance results are not "
                                       "automatically portable across characters.",
            },
        },
        "COA_CLASS_FORMS_ARE_MACRO_ADDRESSABLE": {
            "tier": "CHAT PROBE (hand-transcribed). One class, one form - a positive case, "
                    "not a survey.",
            "THE_FIND": "CoA's CUSTOM CLASSES USE THE STOCK SHAPESHIFT REGISTRY. So [form:N] "
                        "/ [stance:N] is a REAL, WORKING macro lever for a CoA class form - "
                        "and form/stance are already SUPPORTED-PROVEN in `flags`. Usable in a "
                        "macro today.",
            "evidence": "Battlewrath on his BLOODMAGE, 2026-07-17: GetNumShapeshiftForms()=1 "
                        "· GetShapeshiftForm()=1 · GetShapeshiftFormInfo(1) = "
                        "('interface/icons/Spell_Nature_WispSplode', 'Sanguine essence', "
                        "isActive=1, isCastable=1).",
            "the_join": "Bloodmage = api token SONOFARUGAL, classId 20 (Weak Auras/engine/"
                        "Fact_basis/maps/class_table.json, wa_load_verified). The custom-class "
                        "token is an opaque codename you cannot guess - which is exactly why "
                        "that join exists.",
            "so_concretely": "on a Bloodmage, [form:1] / [stance:1] gates on Sanguine essence.",
            "battlewrath_hypothesis": {
                "his_words": "'I think the determining factor for form, is if it has a stance "
                             "bar attached.'",
                "status": "POSITIVE CONFIRMATION; the negative half is still open.",
                "confirmed": "Sanguine essence IS in the shapeshift registry (NF=1, name "
                             "returned, isActive=1) AND is visible to GetShapeshiftForm "
                             "(cur=1). Registry membership and visibility travel together.",
                "the_mechanism_the_source_supports": "the STANCE BAR (ShapeshiftBarFrame, "
                                                     "ShapeshiftButton1..12) is driven by "
                                                     "GetNumShapeshiftForms / "
                                                     "GetShapeshiftFormInfo - the SAME "
                                                     "registry GetShapeshiftForm reports on. "
                                                     "The stance bar is the VISIBLE FACE of "
                                                     "that registry: one mechanism, both "
                                                     "symptoms. A buff-form is not in the "
                                                     "registry at all, so there is no bar and "
                                                     "nothing for GetShapeshiftForm to see.",
                "still_open": "the NEGATIVE case - run it on the REAPER in the spell-form the "
                              "capture read as INVISIBLE (shapeshiftForm=0 while he was "
                              "demonstrably in a form). If NF=0 there, it is settled.",
            },
            "MY_ERROR_KEPT_ON_PURPOSE": {
                "what_I_did": "I was about to assert 'bonusBarOffset IS the stance bar' and "
                              "test the hypothesis with it. Battlewrath stopped me: 'Is that "
                              "what bonusbar is?'",
                "what_the_source_says": "NO. ShapeshiftBarFrame (the stance bar - a row of "
                                        "form buttons) and BonusActionBarFrame (the MAIN "
                                        "action bar replacement) are DIFFERENT FRAMES. They "
                                        "merely live in the same file, which is what made "
                                        "them look like one thing. The archive agrees: "
                                        "bonusbar:5 = 'the possess bar is active' - a "
                                        "main-bar takeover, not a stance row.",
                "why_the_correlation_fooled_me": "shapeshiftForm and bonusBarOffset move "
                                                 "together in 4/4 observations - but these "
                                                 "forms simply BRING their own bar. Two "
                                                 "effects of one state. CO-OCCURRENCE, NOT "
                                                 "MECHANISM.",
                "the_rule": "THE STAMP IS EVIDENCE OF STATE; IT IS NOT A THEORY OF MECHANISM. "
                            "I collapsed those under pressure to have an answer, and the "
                            "correct instrument (GetNumShapeshiftForms) was there the whole "
                            "time.",
            },
        },
        "CHAT_PROBE_FOLLOWUP": CHAT_PROBE,
        "PVP_IS_INVISIBLE_TO_MACROS_HERE": {
            "finding": "PVP state is RICHLY available to the API and NOT ONE macro conditional "
                       "exposes it. A macro on this client CANNOT behave differently in PVP.",
            "the_states_are_real": "Battlewrath, 2026-07-17: 'there is instanced PVP, Duels, "
                                   "and then also engaging an enemy player.' Confirmed by the "
                                   "census: UnitIsPVP · UnitIsPVPFreeForAll · "
                                   "GetBattlefieldStatus · StartDuel · GetZonePVPInfo · "
                                   "IsInInstance · UnitIsPlayer are ALL resident.",
            "but_the_vocabulary_has_no_pvp": "the WotLK-era archive's Complete list contains NO "
                                             "pvp conditional at all - its only PvP mention is "
                                             "prose about /targetenemyplayer. The one "
                                             "pvp-NAMED conditional, [pvpcombat], is 7.3.0 "
                                             "(Legion) and means 'PvP talents are usable' - a "
                                             "system this client does not have (census: ZERO "
                                             "PvpTalent APIs). It is IGNORED.",
            "so_the_only_combat_awareness_is": "[combat] - and it does NOT know who you are "
                                               "fighting. No macro can distinguish PVP from "
                                               "PVE on this client.",
            "the_LAYER_lesson": "Battlewrath, 2026-07-17: 'It might have engine flags for "
                                "different damage profiles. And deminishing returns are a "
                                "thing. But both of those are gameplay concerns. Not macro "
                                "form semantics.' Exactly - and this is the proof. The engine "
                                "can hold as much PVP state as it likes; the parser only sees "
                                "what was FLATTENED INTO A KEYWORD. A gameplay concern that "
                                "was never flattened is invisible to the macro layer, no "
                                "matter how real it is in the game. **Do not reason from "
                                "gameplay to macro capability.**",
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
