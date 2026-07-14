"""
gate.py - the PRE-FLIGHT WORD-MATCH (engine, AT the line).

Catches correctness BEFORE the docket forms: word-matches every token in a docket against the known-sources, so nothing
invented reaches the pipeline. Below the line everything TRUSTS the docket is WA-literal - this is what makes that safe.
It would have stopped my own `treat`/`facet` cold.

Every field is AGENT INPUT - open boxes + select boxes in WA's contract. The gate validates the input is CORRECT:
  KEY            -> a real WA field?                         no -> MALFORM   (invented/typo field)     [BLOCKS]
  select box     -> value is one of the field's domain?      no -> INVALID   (wrong enum)              [BLOCKS]
  spell-id box   -> id exists in the spell corpus?           no -> INVALID   (typo / corpus gap)       [BLOCKS]
                    (WA also validates the id LIVE in-game; the corpus is our offline stand-in for that check)
  open box       -> no offline source to validate content       -> UNCHECKED (WA validates it live)    [soft]
  id / uid       -> IDENTITY (the docket's only human character; never validated)
Correct input is an AGREEMENT and stays SILENT. The report is BY-EXCEPTION: `flags` = the disagreements
(malform + invalid + unchecked). BLOCKS = malform + invalid (incorrect input); unchecked is soft. EPHEMERAL.

Known-sources: contract.json (WA vocab + domains), coa_spells.json (spell corpus; absent -> unchecked, not blocked).

  gate(docket_dict) -> {"passed": bool, "flags": [...], "verdicts": [...], "blocking": [...]}
  py gate.py [--verbose] <docket.json>
"""
import json
import os
import sys

_THIS = os.path.dirname(os.path.abspath(__file__))
CONTRACT = os.path.join(_THIS, "Fact_basis", "contract", "contract.json")
CLASSDATA = os.path.join(_THIS, "..", "..", "dependencies", "coa_spells.json")   # moved to tracked deps/ (was Outputs/spell_dbc)
DOMAINS = os.path.join(_THIS, "Fact_basis", "sheets", "domains.json")

ID_REF_FIELDS = {"spellIds", "spellid1"}                       # values are spell IDs -> checkable vs class-data
NAME_REF_FIELDS = {"auranames", "name1", "spellName"}          # values are names -> user-input (no name index yet)
IDENTITY_KEYS = {"id", "uid"}


def _load(path):
    return json.load(open(path, encoding="utf-8")) if os.path.exists(path) else None


def _as_list(v):
    return v if isinstance(v, list) else [v]


def gate(docket, contract=None, classdata=None, domains=None):
    contract = contract if contract is not None else _load(CONTRACT)
    if domains is None:
        domains = (_load(DOMAINS) or {}).get("domains", {})
    v = []
    def mark(path, verdict, note=""):
        v.append({"path": path, "verdict": verdict, "note": note})

    for k in IDENTITY_KEYS:
        if k in docket:
            mark(k, "identity")

    region = docket.get("region", docket.get("regionType"))
    if region is not None:
        ok = region in contract.get("display", {})
        mark("region", "known-field" if ok else "malform", "" if ok else "%r not a known regionType" % region)

    for i, t in enumerate(docket.get("triggers", []) or []):
        tp = "triggers[%d]" % i
        ttype, event = t.get("type"), t.get("event")
        events = contract.get("trigger", {}).get(ttype)
        if events is None:
            mark(tp + ".type", "malform", "%r not a known trigger type" % ttype); continue
        mark(tp + ".type", "known-field")
        surface = events.get(event)
        if surface is None:
            mark(tp + ".event", "malform", "%r not an event of %s" % (event, ttype)); continue
        mark(tp + ".event", "known-field")
        inputs = surface.get("inputs", {})
        for key, val in (t.get("declare") or {}).items():
            fp = "%s.declare.%s" % (tp, key)
            io = inputs.get(key)
            if io is None:
                mark(fp, "malform", "%r not a field of %s/%s" % (key, ttype, event)); continue
            dom = io.get("domain")
            if isinstance(dom, str):                          # a domain REFERENCE -> resolve via domains.json
                dom = domains.get(dom)
            if isinstance(dom, dict):                         # a SELECT box: the value must be one of the domain's
                bad = [x for x in _as_list(val) if str(x) not in dom and x not in dom]
                mark(fp, "known-value" if not bad else "invalid",
                     "" if not bad else "value(s) %s not in domain %r - incorrect input" % (bad, io.get("domain")))
            elif key in ID_REF_FIELDS:                        # an OPEN BOX you type a spell id into - validate it's REAL
                if classdata is None:                         # (WA validates live in-game; the corpus is our offline stand-in)
                    mark(fp, "unchecked", "no spell corpus to validate the id against")
                else:
                    bad = [x for x in _as_list(val) if str(x) not in classdata]
                    mark(fp, "valid" if not bad else "invalid",
                         "" if not bad else "spell id(s) %s not in the corpus - typo, or a corpus gap" % bad)
            else:                                             # an open box with no offline source to check the content
                mark(fp, "unchecked", "open input - validated live by WA, not offline")

    load = docket.get("load") or {}
    if "class" in load:                                       # an open box; class_table is a candidate source (not wired yet)
        mark("load.class", "unchecked", "class token - no offline source wired yet (class_table is a candidate)")

    # by-EXCEPTION: report only where the input is NOT confirmed-correct. Every field is agent input; the gate validates
    # it. INCORRECT input BLOCKS - malform (KEY isn't a WA field) + invalid (VALUE wrong: bad enum / id not in corpus).
    # UNCHECKED input is soft (an open box with no offline source - WA validates it live). Correct input is an AGREEMENT
    # and stays SILENT (identity/known-field/known-value/valid) - listing it buries the one that matters. `verdicts`
    # keeps the full list for a --verbose audit; `flags` is the headline + what lands beside the docket.
    BLOCK = ("malform", "invalid")
    flags = [x for x in v if x["verdict"] in ("malform", "invalid", "unchecked")]
    return {"passed": not any(x["verdict"] in BLOCK for x in v),
            "flags": flags, "verdicts": v,
            "blocking": [x for x in v if x["verdict"] in BLOCK]}


def main():
    argv = [a for a in sys.argv[1:] if not a.startswith("-")]
    verbose = "-v" in sys.argv or "--verbose" in sys.argv
    if not argv:
        sys.exit("usage: py gate.py [--verbose] <docket.json>")
    docket = json.load(open(argv[0], encoding="utf-8"))
    r = gate(docket, classdata=_load(CLASSDATA))
    for x in (r["verdicts"] if verbose else r["flags"]):          # by-exception unless --verbose
        print("  %-11s %-30s %s" % (x["verdict"], x["path"], x["note"]))
    if not r["flags"]:
        print("  clean - every input confirmed correct")
    if r["passed"]:
        soft = len(r["flags"])
        print("\nGATE: PASS%s" % (" - %d unchecked to confirm" % soft if soft else ""))
    else:
        print("\nGATE: BLOCKED x%d (malform/invalid - incorrect input) - back to inventory" % len(r["blocking"]))


if __name__ == "__main__":
    main()
