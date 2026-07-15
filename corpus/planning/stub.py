"""
stub.py - the REVERSE GEAR (corpus/planning incubator): WA aura -> docket. Strip everything that is not authored
intent, crawling the known-active states from the maps. Then PROVE each stub by closure: press the docket back
through the real gears (fill -> bounce) and diff against the original via the known-deltas registry - CLEAN means
the aura is perfectly understood; novel deltas name the missing map (a finding, not a failure).

The strip stack (each layer cites its knowledge source):
  1. client furniture / registry     known_deltas.json (tocversion, activeTriggerMode stamp, inserted default subs...)
  2. sheet defaults                  display sheets (per-option `default`), aura2 seed state
  3. dead residue                    live_keys.json (aura2 keys the handler never reads; absent-from-map = deader)
  4. participation law               arg_shapes gate x trigger_args (args whose use_ gate is off and not required)
  5. container reduction             triggers dict->list + activation; conditions changes list->map; empty canon blocks

NOT precious, NOT authority: the input is learning material; unknowns are KEPT + FLAGGED (the gap-finder duty).

  py stub.py <import.txt>          -> out/<slug>.docket.json per aura + the closure report
"""
import json
import os
import re
import sys

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.normpath(os.path.join(_THIS, "..", ".."))
_WA = os.path.join(_ROOT, "Weak Auras")
sys.path.insert(0, _WA)
sys.path.insert(0, os.path.join(_WA, "plane"))
sys.path.insert(0, os.path.join(_ROOT, "creator", "verification"))
import weakaura_codec as wc
import fill as fillmod
import reconcile as rec

_FB = os.path.join(_WA, "engine", "Fact_basis")
LIVE = json.load(open(os.path.join(_FB, "maps", "live_keys.json"), encoding="utf-8"))
TARGS = json.load(open(os.path.join(_FB, "maps", "trigger_args.json"), encoding="utf-8"))
REG = json.load(open(os.path.join(_ROOT, "creator", "verification", "known_deltas.json"), encoding="utf-8"))["signatures"]
A2SHEET = json.load(open(os.path.join(_FB, "sheets", "trigger", "aura2.json"), encoding="utf-8"))
LOADSHEET = json.load(open(os.path.join(_FB, "sheets", "load", "load.json"), encoding="utf-8"))
OUT = os.path.join(_THIS, "out")

# region sheets: option -> default (the canon layer)
_REGDEF = {}
for f in os.listdir(os.path.join(_FB, "sheets", "display")):
    if f.endswith(".json") and not f.startswith("_"):
        d = json.load(open(os.path.join(_FB, "sheets", "display", f), encoding="utf-8"))
        opts = d.get("options", {})
        items = opts.items() if isinstance(opts, dict) else ((o.get("name"), o) for o in opts)
        _REGDEF[d.get("region_type") or f[:-5]] = {n: o.get("default") for n, o in items}
_DG_SURFACE = json.load(open(os.path.join(_FB, "sheets", "display", "dynamicgroup.json"), encoding="utf-8"))
_DG_LEVERS = {n: v.get("default") for n, v in (_DG_SURFACE.get("option_surface", {}).get("levers") or {}).items()}

A2_LIVE = {k for k, v in LIVE.get("aura2", {}).get("keys", {}).items() if v.get("live")}
A2_SEED = (A2SHEET["events"][0].get("default_state") or {})            # {type, debuffType HELPFUL, unit player}
LOAD_TYPES = {c["name"]: c.get("type") for c in LOADSHEET.get("conditions", [])}
_CONTRACT = json.load(open(os.path.join(_FB, "contract", "contract.json"), encoding="utf-8"))
CUSTOM_INPUTS = set((_CONTRACT.get("trigger", {}).get("custom", {}).get("Custom", {}) or {}).get("inputs", {}))

# aura-level keys that are pure canon/client scaffolding when default-shaped (dropped if equal to these)
_CANON_BLOCKS = {
    "animation": {"start": {"easeStrength": 3, "type": "none", "duration_type": "seconds", "easeType": "none"},
                  "main": {"easeStrength": 3, "type": "none", "duration_type": "seconds", "easeType": "none"},
                  "finish": {"easeStrength": 3, "type": "none", "duration_type": "seconds", "easeType": "none"}},
    "actions": {"start": [], "finish": [], "init": []},
    "information": [], "authorOptions": [], "config": [],
    "conditions": [],
}
_IDENTITY = ("id", "uid", "regionType", "parent", "internalVersion", "tocversion", "preferToUpdate",
             "source", "semver", "version", "url", "wagoID")


def _neq(a, b):
    try:
        return float(a) != float(b)
    except (TypeError, ValueError):
        return a != b


def _companions(name):
    return {"use_" + name, "use_exact_" + name, name + "_operator", name + "_caseInsensitive"}


def strip_trigger(t, flags, ledger):
    """one trigger table -> {type, event, declare}; deliberate drops recorded in the residue LEDGER."""
    t = dict(t)
    ttype, event = t.pop("type", None), t.pop("event", None)
    declare = {}
    if ttype == "custom":
        # the custom trigger is NOT prototype-driven - its surface comes from the contract's custom/Custom
        # inputs (the scaffold fields: custom_type/check/events/custom/customDuration/...). Keying by the STORED
        # event name mis-strips the whole scaffold (first custom through the gear did exactly that - the events
        # box stores "Combat Log"-ish residue while the real gate event is "Custom").
        if event != "Custom":
            ledger.add("event")
            event = "Custom"
        allow = set(CUSTOM_INPUTS)
        for name in list(CUSTOM_INPUTS):
            allow |= _companions(name)
        for k, v in t.items():
            if k in allow and v is not None:
                declare[k] = v
            elif v is not None:
                ledger.add(k)
    elif ttype == "aura2":
        if event != "Aura":
            ledger.add("event")                                 # stored event on aura2 is inert residue
            event = "Aura"                                      # the sheet's single real event (gate-correct)
        for k, v in t.items():
            if k not in A2_LIVE:
                ledger.add(k)                                   # residue or never-accessed - dead either way
                continue
            declare[k] = v
        # participation: gated pairs where the gate is off/absent drop together (LEDGERED - touched-off residue)
        for gate, val in (("useName", "auranames"), ("useExactSpellId", "auraspellids"),
                          ("useIgnoreName", "ignoreAuraNames"), ("useIgnoreExactSpellId", "ignoreAuraSpellids")):
            if not declare.get(gate):
                if gate in declare or val in declare:
                    ledger.update({gate, val})
                declare.pop(gate, None); declare.pop(val, None)
    else:
        args = {a["name"]: a for a in TARGS.get("triggers", {}).get(event, [])}
        if not args:
            flags.append("trigger %s/%s: no prototype args on the map - declare kept whole" % (ttype, event))
            declare = {k: v for k, v in t.items() if v not in ([], {})}
        else:
            # allowlist = args + companions. NOTE: event-prototype triggers are consumed by GenericTrigger's test
            # path, NOT ConstructFunction:815 (that's the LOAD law) - ungated selects still count. So v1 keeps every
            # PRESENT arg; the trigger-side participation law is a named wall (harvest GenericTrigger later).
            allow = set()
            for name in args:
                allow |= {name} | _companions(name)
            for k, v in t.items():
                if k in allow and v is not None:
                    declare[k] = v
                elif v is not None:
                    ledger.add(k)                               # not an arg of THIS event = type-switch residue
    return {"type": ttype, "event": event, "declare": declare}


def strip_load(load, flags):
    out = {}
    for name, ty in LOAD_TYPES.items():
        gate = load.get("use_" + name)
        if gate is None:
            continue                                            # not participating (WeakAuras.lua:814)
        out["use_" + name] = gate
        v = load.get(name)
        if isinstance(v, dict):
            m = {k: True for k, on in (v.get("multi") or {}).items() if on} if not gate else None
            if gate and v.get("single") is not None:
                out[name] = {"single": v["single"]}
            elif m:
                out[name] = {"multi": m}
        elif v is not None:
            out[name] = v
    unknown = {k for k in load if k not in LOAD_TYPES and not k.startswith("use_")
               and k.rsplit("_", 1)[0] not in LOAD_TYPES} - {"size", "spec"}
    for k in sorted(unknown):
        flags.append("load.%s: not on the load sheet - kept" % k); out[k] = load[k]
    return out


def strip_aura(a, flags):
    d = {"id": a.get("id"), "uid": a.get("uid"), "regionType": a.get("regionType")}
    ledger = set()                                              # what we DELIBERATELY dropped (residue)
    trigs = a.get("triggers")
    nums, extras = ([], {})
    if isinstance(trigs, list):
        nums = [x.get("trigger", x) for x in trigs]
    elif isinstance(trigs, dict):
        nums = [trigs[k]["trigger"] for k in sorted((k for k in trigs if str(k).isdigit()), key=int)]
        extras = {str(k): v for k, v in trigs.items() if not str(k).isdigit()}
    d["triggers"] = [strip_trigger(t, flags, ledger) for t in nums]
    d["_residue"] = sorted(ledger)                              # the ledger rides in the envelope (stripped, on record)
    activation = {k: v for k, v in extras.items()
                  if not (k == "activeTriggerMode" and v == -10)}      # the client stamp (registry)
    if activation:
        d["activation"] = activation
    # display: region options where stored != sheet default; unknown fields kept+flagged
    regdef = _REGDEF.get(d["regionType"], {})
    display = {}
    for k, v in a.items():
        if k in _IDENTITY or k in ("triggers", "load", "subRegions", "conditions") or k in _CANON_BLOCKS:
            continue
        if k in regdef:
            if _neq(v, regdef[k]):
                display[k] = v
        elif k in _DG_LEVERS:
            if _neq(v, _DG_LEVERS[k]):
                display[k] = v
        elif k in ("xOffset", "yOffset", "frameStrata", "anchorFrameType", "anchorPoint", "selfPoint",
                   "alpha", "width", "height", "frameStrataOrder", "anchorFrameFrame", "controlledChildren",
                   "sortHybridTable", "useAdjustededMax", "useAdjustededMin", "scale"):
            if k in ("xOffset", "yOffset") and _neq(v, 0):
                display[k] = v                                   # position = the MASK's material - keep non-zero
            elif k in ("width", "height", "scale", "alpha") and v is not None:
                display[k] = v                                   # size/feel - keep (mask material), canon has no say
        else:
            flags.append("%s.%s: unknown field - kept" % (d["id"], k)); display[k] = v
    if display:
        d["display"] = display
    subs = [s for s in (a.get("subRegions") or [])
            if s.get("type") not in ("subbackground", "subforeground")]  # client inserts (registry)
    if subs:
        d["subregions"] = subs
    conds = a.get("conditions") or []
    if conds and conds != []:
        d["conditions"] = [dict({k: v for k, v in c.items() if k not in ("check", "changes")},
                                check=c.get("check"),
                                changes={ch.get("property"): ch.get("value") for ch in (c.get("changes") or [])})
                           for c in conds]                      # extra keys (linked, ...) preserved verbatim
    for k, default in _CANON_BLOCKS.items():
        if k in a and a[k] != default and k != "conditions":
            flags.append("%s.%s: non-default canon block - kept whole" % (d["id"], k))
            d.setdefault("display", {})[k] = a[k]
    load = strip_load(a.get("load") or {}, flags)
    if load:
        d["load"] = load
    return d


def _recognize(kind, p, b):
    pn = re.sub(r"\[\d+\]", "[*]", re.sub(r"\[\w+#\d+\]", "[*]", p))
    for s in REG:
        if s["kind"] == kind and re.search(s["path"], pn):
            if s.get("value_to") and not re.search(s["value_to"], json.dumps(b, default=str)):
                continue
            return s
    return None


def closure(docket, original):
    """press the docket back through the REAL gears; diff vs the original through the registry.
    Returns (novel, residue_hits): deltas explained by the residue LEDGER are stripped-residue, not novel."""
    import roundtrip_diff as rd
    pressed = rec.bounce(fillmod.fill(_docketize(docket)))
    residue = set(docket.get("_residue") or [])
    novel, res_hits = [], 0
    for kind, p, a, b in rd.member_deltas(pressed, original):
        if _recognize(kind, p, b):
            continue
        leaf = p.rsplit(".", 1)[-1]
        if leaf in residue:                                     # ADDED/MUTATED/DROPPED alike: the ledger explains it
            res_hits += 1                                       # (the original's residue we deliberately stripped)
            continue
        novel.append((kind, p, a, b))
    return novel, res_hits


def _docketize(d):
    """fill's docket schema; the envelope's underscore keys don't press."""
    dk = {k: v for k, v in d.items() if not k.startswith("_")}
    dk.setdefault("uid", "")
    return dk


def main():
    src = sys.argv[1]
    s = open(src, encoding="utf-8").read().strip()
    try:
        parent, kids = wc.decode_group_import_string(s)
        items = [parent] + list(kids)
    except ValueError:
        items = [wc.decode_import_string(s)]
    os.makedirs(OUT, exist_ok=True)
    print("stubbing %d auras from %s\n" % (len(items), os.path.basename(src)))
    report = []
    for a in items:
        flags = []
        d = strip_aura(a, flags)
        novel, res_hits = None, 0
        try:
            novel, res_hits = closure(d, a)
        except SystemExit as e:
            flags.append("closure press failed: %s" % str(e)[:90])
        except Exception as e:
            flags.append("closure press failed: %s: %s" % (type(e).__name__, str(e)[:90]))
        cl = ("press-failed" if novel is None else
              ("CLEAN" if not res_hits else "CLEAN +%d residue" % res_hits) if novel == [] else
              "%d novel deltas" % len(novel))
        slug = re.sub(r"[^A-Za-z0-9]+", "_", str(d.get("id"))).strip("_")[:48]
        env = {"_provenance": {"source": os.path.basename(src), "origin": "battlewrath-live", "closure": cl}, **d}
        json.dump(env, open(os.path.join(OUT, slug + ".docket.json"), "w", encoding="utf-8"),
                  ensure_ascii=False, indent=1)
        n_decl = sum(len(t.get("declare", {})) for t in d.get("triggers", []))
        report.append((d.get("id"), env["_provenance"]["closure"], n_decl, len(d.get("display", {})), flags, novel))
    for rid, cl, nd, ndisp, flags, novel in report:
        print("%-42s closure: %-16s declares:%2d display:%2d" % (str(rid)[:42], cl, nd, ndisp))
        for f in flags[:4]:
            print("      flag: %s" % f)
        for kind, p, a, b in (novel or [])[:5]:
            print("      NOVEL %-8s %-38s %s -> %s" % (kind, p, json.dumps(a, default=str)[:36], json.dumps(b, default=str)[:36]))
    clean = sum(1 for r in report if r[1] == "CLEAN")
    print("\n%d/%d CLEAN closures -> out/" % (clean, len(report)))


if __name__ == "__main__":
    main()
