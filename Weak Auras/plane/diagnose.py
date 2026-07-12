"""
diagnose.py - a READ tool (no pipeline touch). Crawls the OUR-WA corpus and, per aura,
emits behavioural SIGNALS + faceted FINGERPRINTS, then pivots by method-hash so the
space flattens: methods on one axis, taste on another, residue falling out as noise.

Signals (conceptual intent, not texture):
  combine       - trigger combination: single / any / all / custom  (complexity fprint)
  sources       - inward (own state: cooldown/power/usable) vs outward (aura2/combatlog
                  = proc/minion/target) - the strongest "what kind of aura" signal
  primary_icon  - crawl the trigger gates for the spell that governs the display
  changes       - what the conditions CHANGE (desaturate/color/glow/alpha) - presentation
  persist       - genericShowOn: showAlways (footprint) vs showOn* (alert)
  subregions    - aux info (text=count/stacks, glow)
  scripted      - custom trigger / customcheck / customcode present (inventive frontier)

Fingerprints:
  method_hash   - canonical structural signature (region + trigger events + combine +
                  condition shape + subRegion types + load gates), masking position /
                  content / texture / size. Same hash == same method.
  facets        - the masked-out values kept aside for taste analysis: position, size,
                  anchor, color, content spells.

    py diagnose.py            # writes out/diagnosis.json + out/diagnosis_clusters.json,
                              # prints the top method clusters with facet spread.
"""
import hashlib
import json
import os
import sys
from collections import Counter, defaultdict

sys.stdout.reconfigure(encoding="utf-8")

_THIS = os.path.dirname(os.path.abspath(__file__))
_WA = os.path.dirname(_THIS)
_ROOT = os.path.dirname(_WA)
REF = os.path.join(_WA, "ingest", "reference")
CORPUS = os.path.join(_ROOT, "Outputs", "aura_corpus", "battlewrath_displays.json")
OUT = os.path.join(_THIS, "out")

_INWARD = ("Cooldown", "Action Usable", "Charges", "Global Cooldown", "Queued Action",
           "Spell Known", "Talent", "Stance", "Swing", "Equipment", "Item Count")
_OUTWARD = ("Aura", "Buff", "Debuff", "Combat Log", "Cast", "Range", "Threat",
            "Encounter", "Crowd Controlled")
_GROUPS = ("group", "dynamicgroup")


def pool():
    """Yield (source_label, aura_node) for every non-retail corpus aura."""
    for f in sorted(os.listdir(REF)):
        if not f.endswith(".json") or f.startswith("Retail_"):
            continue
        rec = json.load(open(os.path.join(REF, f), encoding="utf-8"))
        if rec.get("provenance", {}).get("origin") == "retail":
            continue
        for n in [rec.get("root")] + (rec.get("children") or []):
            if isinstance(n, dict):
                yield f, n
    if os.path.exists(CORPUS):
        for k, n in json.load(open(CORPUS, encoding="utf-8")).items():
            if isinstance(n, dict):
                yield f"corpus:{k}", n


def triggers_of(node):
    """[(index, trigger_core)] in numeric order."""
    trg = node.get("triggers", {})
    items = trg.items() if isinstance(trg, dict) else enumerate(trg or [])
    out = []
    for k, v in items:
        ks = str(k)
        if ks.isdigit() and isinstance(v, dict) and isinstance(v.get("trigger"), dict):
            out.append((int(ks), v["trigger"]))
    return sorted(out)


def combine(node):
    trg = node.get("triggers", {})
    d = trg.get("disjunctive") if isinstance(trg, dict) else None
    n = len(triggers_of(node))
    if n <= 1:
        return "single"
    return d or "all"          # WA default when 2+ triggers and no disjunctive set


def classify_source(t):
    event = t.get("event") or ""
    if t.get("type") == "custom" or (t.get("custom") and not event):
        return "scripted"
    if any(k in event for k in _OUTWARD):
        return "outward"
    if any(k in event for k in _INWARD):
        return "inward"
    if event in ("Power", "Health"):
        return "inward" if t.get("unit") in (None, "player") else "outward"
    # fall back on unit: a non-player unit read is looking outward
    if t.get("unit") not in (None, "player", ""):
        return "outward"
    return "other"


def native_signal(t):
    """The NATIVE game signal a trigger READS - keyed on trigger TYPE, because `event` is
    RESIDUE on aura2 (grounded in the corpus: 173 aura2 triggers carry a stale event=Health,
    etc.; a clean aura2 has event=None). A WA reads native state and flattens it - this names
    which state. `[[wa-reads-and-flattens-native-state]]`"""
    ty = t.get("type")
    if ty in ("aura2", "aura"):
        return "buff-window"       # the Aura/BuffTrigger2 read: present / stacks / remaining
    if ty == "custom":
        return "scripted"
    if ty == "combatlog":
        return "combat-event"
    if ty == "item":
        return "item"
    ev = t.get("event") or ""
    if ty == "spell":
        if "Cooldown" in ev:
            return "cooldown"
        if ev == "Totem":
            return "totem"
        return "usable"            # Action Usable / Spell Known / Global Cooldown
    if ty == "unit":
        if ev == "Health":
            return "health"
        if ev in ("Power", "Combo Points", "Death Knight Rune"):
            return "resource"
        if ev == "Cast":
            return "cast"
        if ev == "Swing Timer":
            return "swing"
        return "unit-state"        # Unit Characteristics / Stance-Form-Aura / Conditions / Threat
    return "other"


def spell_of(t):
    for f in ("spellName", "spellId", "auranames", "spellIds", "names"):
        v = t.get(f)
        if isinstance(v, list) and v:
            return v[0]
        if v not in (None, "", 0):
            return v
    return None


def primary_icon(node):
    """Crawl trigger gates for the spell that would govern the display. Static icon wins
    if explicitly set; else the first spell-bearing trigger."""
    if node.get("displayIcon"):
        return {"kind": "static", "value": node["displayIcon"]}
    for _, t in triggers_of(node):
        s = spell_of(t)
        if s is not None:
            return {"kind": "spell", "value": s}
    return {"kind": "none", "value": None}


def condition_shapes(node):
    """[(checked variables, set properties)] - the logic shape, values dropped."""
    shapes = []
    for c in node.get("conditions") or []:
        if not isinstance(c, dict):
            continue
        chk = c.get("check", {})
        variables = []

        def walk(x):
            if isinstance(x, dict):
                if x.get("variable"):
                    variables.append(x["variable"])
                for sub in (x.get("checks") or []):
                    walk(sub)
        walk(chk)
        props = [ch.get("property") for ch in (c.get("changes") or [])
                 if isinstance(ch, dict) and ch.get("property")]
        shapes.append({"vars": sorted(set(variables)), "sets": sorted(set(props))})
    return shapes


def signals(node):
    trs = triggers_of(node)
    srcs = Counter(classify_source(t) for _, t in trs)
    changes = sorted({p for s in condition_shapes(node) for p in s["sets"] if p})
    scripted = "scripted" in srcs or any(
        t.get("customCheck") or t.get("custom") for _, t in trs)
    gen = next((t.get("genericShowOn") for _, t in trs if t.get("genericShowOn")), None)
    return {
        "region": node.get("regionType"),
        "n_triggers": len(trs),
        "combine": combine(node),
        "sources": dict(srcs),
        "primary_icon": primary_icon(node),
        "changes": changes,
        "persist": gen,
        "subregions": [s.get("type") for s in (node.get("subRegions") or []) if isinstance(s, dict)],
        "scripted": bool(scripted),
        "load_gates": sorted(k for k, v in (node.get("load") or {}).items()
                             if k.startswith("use_") and v),
    }


def _settled_event(t):
    """The trigger's LIVE namespace for clustering — not its stored (maybe residue) `event`.
    aura2/aura -> 'Aura' (event is residue there); else the real prototype event. Same
    type-first resolution as native_signal, so pivot/subjects/method_hash flatten on live gates,
    not the full history of creation. `[[stored-field-isnt-live-check-consumption]]`"""
    ty = t.get("type")
    if ty in ("aura2", "aura"):
        return "Aura"
    return t.get("event")


def method_signature(node):
    """Canonical structural essence - position/content/texture/size masked out."""
    return {
        "region": node.get("regionType"),
        "triggers": [{"event": _settled_event(t), "type": t.get("type")} for _, t in triggers_of(node)],
        "combine": combine(node),
        "conditions": condition_shapes(node),
        "subregions": [s.get("type") for s in (node.get("subRegions") or []) if isinstance(s, dict)],
        "load_gates": sorted(k for k, v in (node.get("load") or {}).items()
                             if k.startswith("use_") and v),
    }


def facets(node):
    """Masked-out values kept aside for taste analysis."""
    col = node.get("color")
    return {
        "pos": [node.get("xOffset"), node.get("yOffset")],
        "anchor": [node.get("anchorPoint"), node.get("selfPoint"), node.get("anchorFrameType")],
        "size": [node.get("width"), node.get("height")],
        "color": tuple(col) if isinstance(col, list) else None,
        "desaturate": node.get("desaturate"),
        "spell": (primary_icon(node) or {}).get("value"),
    }


def diagnose_one(source, node):
    sig = method_signature(node)
    h = hashlib.sha1(json.dumps(sig, sort_keys=True).encode()).hexdigest()[:12]
    return {"source": source, "id": node.get("id"), "method_hash": h,
            "signals": signals(node), "method_sig": sig, "facets": facets(node)}


def _human_method(sig):
    ev = "+".join((t["event"] or t["type"] or "?") for t in sig["triggers"]) or "(no-trigger)"
    cond = ",".join(">".join(("/".join(s["vars"]) or "-", "/".join(s["sets"]) or "-"))
                    for s in sig["conditions"]) or "-"
    subs = "+".join(sig["subregions"]) or "-"
    return f"{sig['region']} | {ev} [{sig['combine']}] | cond:{cond} | sub:{subs}"


def _hashable(v):
    return json.dumps(v, sort_keys=True) if isinstance(v, (list, dict)) else v


# ---- inspection keys -----------------------------------------------------------
def subject_key(r):
    """SUBJECT = region + trigger events + combine (what kind of thing) - the grain
    for naming a behaviour; its condition-methods below are the canonical + antis."""
    s = r["method_sig"]
    ev = tuple((t["event"] or t["type"] or "?") for t in s["triggers"])
    return (s["region"], ev, s["combine"])


def subject_label(k):
    region, ev, comb = k
    return f"{region} | {'+'.join(ev) or '(no-trigger)'} [{comb}]"


def cond_key(r):
    return " & ".join("/".join(c["vars"]) + "->" + "/".join(c["sets"])
                      for c in r["method_sig"]["conditions"]) or "(no condition)"


def load_rows():
    """Read the cached readout if present, else crawl + write it."""
    p = os.path.join(OUT, "diagnosis.json")
    if os.path.exists(p):
        return json.load(open(p, encoding="utf-8"))
    rows = [diagnose_one(s, n) for s, n in pool()]
    os.makedirs(OUT, exist_ok=True)
    json.dump(rows, open(p, "w", encoding="utf-8"), indent=1, ensure_ascii=False)
    return rows


def _subjects(rows):
    subj = defaultdict(list)
    for r in rows:
        subj[subject_key(r)].append(r)
    return sorted(subj.items(), key=lambda kv: -len(kv[1]))


def cmd_pivot(rows):
    """Default view: crawl summary + method-hash clusters."""
    clusters = defaultdict(list)
    for r in rows:
        clusters[r["method_hash"]].append(r)
    ranked = sorted(clusters.values(), key=len, reverse=True)
    groups = sum(1 for r in rows if r["signals"]["region"] in _GROUPS)
    print(f"{len(rows)} auras  |  {len(clusters)} methods  |  {len(_subjects(rows))} subjects  "
          f"|  {groups} containers")
    print("top methods (x = auras sharing the exact method):\n")
    summary = []
    for cl in ranked[:20]:
        r0 = cl[0]
        spread = {f: len({_hashable(x["facets"][f]) for x in cl})
                  for f in ("pos", "size", "color", "spell")}
        print(f"  x{len(cl):<4} {_human_method(r0['method_sig'])[:94]}")
        print(f"        spread: pos={spread['pos']} size={spread['size']} "
              f"color={spread['color']} spell={spread['spell']}")
        summary.append({"method_hash": r0["method_hash"], "count": len(cl),
                        "method": _human_method(r0["method_sig"]), "distinct": spread})
    json.dump(summary, open(os.path.join(OUT, "diagnosis_clusters.json"), "w", encoding="utf-8"),
              indent=1, ensure_ascii=False)
    print("\nnext: `py diagnose.py subjects`  |  `py diagnose.py inspect <#|text>`")


def cmd_subjects(rows):
    """List behaviour subjects (naming grain), ranked, with their method-variant count."""
    ranked = _subjects(rows)
    print(f"{len(ranked)} subjects (region+trigger+combine) - the naming grain:\n")
    for i, (k, ms) in enumerate(ranked):
        variants = len({cond_key(r) for r in ms})
        scripted = "*" if any(r["signals"]["scripted"] for r in ms) else " "
        src = Counter(s for r in ms for s in r["signals"]["sources"])
        io = "out" if src.get("outward") else ("scr" if src.get("scripted") else "in")
        print(f"  [{i:>3}]{scripted} x{len(ms):<4} {io:>3}  {subject_label(k)[:78]}  "
              f"({variants} methods)")
    print("\ninspect one: `py diagnose.py inspect <#>`  (or a text fragment of the label)")


def cmd_inspect(rows, arg):
    """Drill a subject into its condition-method spectrum (canonical + anti-assertions),
    each with persistence, subregions, exemplars, and taste spread."""
    ranked = _subjects(rows)
    if arg.lstrip("-").isdigit():
        pick = ranked[int(arg)]
    else:
        hits = [x for x in ranked if arg.lower() in subject_label(x[0]).lower()]
        if not hits:
            raise SystemExit(f"no subject matches {arg!r}. try `py diagnose.py subjects`")
        if len(hits) > 1:
            print(f"{len(hits)} subjects match {arg!r}:")
            for k, ms in hits[:12]:
                print(f"  x{len(ms):<4} {subject_label(k)}")
            print("narrow the text, or use the [#] from `subjects`.")
            return
        pick = hits[0]
    k, members = pick
    variants = defaultdict(list)
    for r in members:
        variants[cond_key(r)].append(r)
    print(f"SUBJECT  {subject_label(k)}")
    print(f"  {len(members)} auras, {len(variants)} condition-methods "
          f"(canonical + anti-assertions, ranked):\n")
    for ck, ms in sorted(variants.items(), key=lambda kv: -len(kv[1])):
        persist = sorted({str(r["signals"]["persist"]) for r in ms})
        subs = sorted({"+".join(r["signals"]["subregions"]) or "-" for r in ms})
        spread = {f: len({_hashable(x["facets"][f]) for x in ms})
                  for f in ("pos", "size", "color", "spell")}
        print(f"  x{len(ms):<3} {ck}")
        print(f"        persist={persist} sub={subs[:3]}{'...' if len(subs) > 3 else ''} "
              f"| spread pos={spread['pos']} size={spread['size']} spell={spread['spell']}")
        for r in ms[:3]:
            print(f"        e.g. {str(r['source'])[:32]:32} id={str(r.get('id'))[:24]:24} "
                  f"spell={r['facets']['spell']}")
        print()


def cmd_lens():
    """The signal->reader lens: index the corpus by which NATIVE signal each aura reads,
    and how it's shown/gated. Proves, empirically, the patterns people care about."""
    trig_freq = Counter()
    aura_freq = Counter()
    combos = Counter()
    inv_region = defaultdict(Counter)
    inv_change = defaultdict(Counter)
    n = 0
    for src, node in pool():
        n += 1
        sigs = [native_signal(t) for _, t in triggers_of(node)]
        for s in sigs:
            trig_freq[s] += 1
        sset = frozenset(sigs) or frozenset({"(no-trigger)"})
        for s in sset:
            aura_freq[s] += 1
        combos[sset] += 1
        region = node.get("regionType")
        changes = sorted({p for c in condition_shapes(node) for p in c["sets"] if p})
        for s in sset:
            inv_region[s][region] += 1
            for ch in changes:
                inv_change[s][ch] += 1
    print(f"=== {n} corpus auras — the native signals people actually READ ===\n")
    print("what people care about (auras reading each signal, + how it's shown):")
    for s, c in aura_freq.most_common():
        shown = ", ".join(f"{r}×{cnt}" for r, cnt in inv_region[s].most_common(3))
        print(f"  {c:4d} ({100*c//n:2d}%)  {s:13} shown: {shown}")
    print("\ntop signal COMPOSITIONS (read together = the real building blocks):")
    for cs, c in combos.most_common(12):
        print(f"  x{c:<3} {' + '.join(sorted(cs))}")
    out = {"count": n,
           "by_signal": {s: {"auras": aura_freq[s], "triggers": trig_freq[s],
                             "shown_as": dict(inv_region[s].most_common()),
                             "gates_changes": dict(inv_change[s].most_common(8))}
                         for s, _ in aura_freq.most_common()},
           "compositions": {" + ".join(sorted(cs)): c for cs, c in combos.most_common()}}
    os.makedirs(OUT, exist_ok=True)
    p = os.path.join(OUT, "signal_index.json")
    json.dump(out, open(p, "w", encoding="utf-8"), indent=1, ensure_ascii=False)
    print(f"\nwrote {os.path.relpath(p, _ROOT)} — signal→reader index (inverted)")


def _aura2_allow():
    """Live-field allowlist for aura2 (buff-window) triggers, from aura_trigger_schema.json.
    `event` is EXCLUDED (it's residue on aura2). Best-effort: the Aura trigger isn't in
    index.json, so this curated schema is a subset — residue here means 'not in our schema',
    not proven-dead. Indexed triggers below are strict/reliable."""
    p = os.path.join(_WA, "wa_index", "aura_trigger_schema.json")
    if not os.path.exists(p):
        return None
    sch = json.load(open(p, encoding="utf-8"))
    allow = {"type", "unit", "debuffType"}
    for ax in ("catch", "resolve", "show", "read"):
        for k, f in (sch.get(ax) or {}).items():
            if k.startswith("_") or not isinstance(f, dict):
                continue
            for key in ("value", "use", "operator", "also"):
                v = f.get(key)
                if isinstance(v, str) and not v.startswith("("):
                    allow.add(v)
    return allow


def _aura2_companions():
    """use_field -> [value/operator/also fields it gates], from aura_trigger_schema. Handles the
    irregular aura naming (e.g. use_tooltip gates fetchTooltip). When the use_ toggle is off, its
    companions go off with it."""
    p = os.path.join(_WA, "wa_index", "aura_trigger_schema.json")
    comp = {}
    if not os.path.exists(p):
        return comp
    sch = json.load(open(p, encoding="utf-8"))
    for ax in ("catch", "resolve", "show", "read"):
        for k, f in (sch.get(ax) or {}).items():
            if k.startswith("_") or not isinstance(f, dict):
                continue
            u = f.get("use")
            if not isinstance(u, str) or u.startswith("("):
                continue
            comp[u] = [f[x] for x in ("value", "operator", "also")
                       if isinstance(f.get(x), str) and not f[x].startswith("(")]
    return comp


def _aura2_defaults():
    """value-field -> default value, from aura_trigger_schema (sourced defaults only)."""
    p = os.path.join(_WA, "wa_index", "aura_trigger_schema.json")
    d = {}
    if not os.path.exists(p):
        return d
    sch = json.load(open(p, encoding="utf-8"))
    for ax in ("catch", "resolve", "show", "read"):
        for k, f in (sch.get(ax) or {}).items():
            if isinstance(f, dict) and "default" in f and isinstance(f.get("value"), str):
                d[f["value"]] = f["default"]
    return d


def _seed_defaults():
    """Per-event, function-driven prototype defaults frozen from WA source by
    wa_index/extract_seed_defaults.py (runs each `init` on an empty trigger). AUTHORITATIVE and
    PER-PROTOTYPE - e.g. Power/Health/Cast unit=player, Range Check/Threat unit=target (NOT a blanket;
    hand-sourcing had wrongly assumed player for all). [[unit-trigger-seeding-and-powertype-content]]"""
    p = os.path.join(_WA, "wa_index", "trigger_seed_defaults.json")
    return json.load(open(p, encoding="utf-8")) if os.path.exists(p) else {}


_SEED_DEFAULTS = _seed_defaults()
# use_unit=true is UI creation-seeding (not an init mutation -> absent from the extracted table);
# live-confirmed family-wide for type:unit triggers. Stays a small live-sourced constant.
_UNIT_UI_SEEDS = {"use_unit": True}


def settle_trigger(t, idx, a2, a2_comp, a2_def):
    """Partition a trigger's stored fields -> (ns, mode, active, off, xtype, defaulted). `active` =
    the LIVE, NON-DEFAULT levers (cross-type residue, touched-off toggles + companions, and
    stored-equals-default all stripped). The engine shared by settle + stub.
    `[[stored-field-isnt-live-check-consumption]]`"""
    import index_schema
    ty = t.get("type")
    slots = None
    if ty in ("aura2", "aura"):
        ns, allow, mode = "Aura(buff-window)", a2, "approx"
    else:
        ns = t.get("event") or ty
        allow, slots = index_schema.trigger_schema(idx, ns)
        mode = "strict" if slots else "unknown-ns"
        if not slots:
            return ns, mode, None, None, None, None
    stored = dict(t)
    ltype = {s["name"]: s.get("type") for s in (slots or [])}
    active, off, xtype = {}, [], []
    for k, v in stored.items():
        if k not in allow:                                  # cross-type residue
            xtype.append(k); continue
        base = k[4:] if k.startswith("use_") else k
        lt = ltype.get(base, ltype.get(k))
        is_toggle = lt == "toggle" or (lt != "tristate" and
                    (k.startswith("use_") or (k[:3] == "use" and k[3:4].isupper())))
        if v is False and is_toggle:                        # touched-then-off (tristate-safe)
            off.append(k)
        else:
            active[k] = v
    off_bases = set()                                       # 2b: companions of off toggles
    for k in off:
        if k.startswith("use_"):
            off_bases.add(k[4:])
        elif k[:3] == "use" and k[3:4].isupper():
            off_bases.add(k[3].lower() + k[4:])
    drop = set()
    for offk in off:
        drop.update(a2_comp.get(offk, []))                  # schema-mapped (irregular aura names)
    for k in list(active):
        if k in drop or any(k == b or k in (b + "Operator", b + "_operator", b + "_name", b + "_count")
                            for b in off_bases):
            off.append(k); del active[k]
    # stage 2c: fold stored-equals-default (a lever at its prototype default was never a real choice)
    if ty in ("aura2", "aura"):
        defaults = {**a2_def, **_SEED_DEFAULTS.get("aura2", {})}   # schema matchesShowOn + extracted seeds (unit/debuffType)
    else:
        defaults = {s["name"]: s.get("default") for s in (slots or []) if s.get("default") is not None}
        defaults.update(_SEED_DEFAULTS.get(ns, {}))     # per-prototype init seeds (WA source; arg-scan misses)
        if ty == "unit":
            defaults.setdefault("use_unit", True)        # UI creation-seed (not an init mutation)
    defaulted = []
    for k in list(active):
        if k in defaults and defaults[k] == active[k]:
            defaulted.append(k); del active[k]
    return ns, mode, active, off, xtype, defaulted


def _settle_ctx():
    import index_schema
    return (json.load(open(CORPUS, encoding="utf-8")), index_schema.load_index(),
            _aura2_allow(), _aura2_companions(), _aura2_defaults())


def _ids_for(corpus, arg):
    ids = [arg]
    top = corpus.get(arg)
    if top and top.get("controlledChildren"):
        ids += list(top["controlledChildren"])
    return ids


def cmd_settle(arg):
    """Diagnostic view: per trigger, ACTIVE (live) vs OFF(touched) vs XTYPE-residue. Raw residue
    stays in the corpus; this just shows what's live."""
    corpus, idx, a2, a2_comp, a2_def = _settle_ctx()
    total_res = 0
    for cid in _ids_for(corpus, arg):
        n = corpus.get(cid)
        if not n:
            print(f"[not found] {cid}"); continue
        print("=" * 74); print(f"AURA  {cid}   | region: {n.get('regionType')}")
        for i, t in triggers_of(n):
            ns, mode, active, off, xtype, defaulted = settle_trigger(t, idx, a2, a2_comp, a2_def)
            if active is None:
                print(f"  trg{i} [{ns}] namespace not indexed; keys: {sorted(t)}"); continue
            total_res += len(xtype) + len(off) + len(defaulted)
            print(f"  trg{i} [{ns}]  ({mode})")
            print("    ACTIVE : " + ("  ".join(f"{k}={str(active[k])[:30]}" for k in sorted(active)) or "(all defaults — no real choices)"))
            print(f"    DEFAULT (folded): {sorted(defaulted) or '-'}")
            print(f"    OFF(touched): {sorted(off) or '-'}")
            print(f"    XTYPE-residue: {sorted(xtype) or '-'}" + ("   (approx)" if mode == "approx" else ""))
    print(f"\n{total_res} inert field(s) — settled to real choices (residue + defaults kept in the corpus).")


def _item_sha(n):
    import hashlib
    return hashlib.sha256(json.dumps(n, sort_keys=True, ensure_ascii=False).encode()).hexdigest()[:16]


def _build_stub(cid, n, idx, a2, a2_comp, a2_def, sha):
    """One aura -> its true-levers stub (residue / off / companions / defaults stripped)."""
    trs = []
    for i, t in triggers_of(n):
        ns, mode, active, off, xtype, defaulted = settle_trigger(t, idx, a2, a2_comp, a2_def)
        if active is None:
            trs.append({"ns": ns, "unsettled": sorted(t)}); continue
        levers = {k: active[k] for k in sorted(active) if k not in ("type", "event")}  # drop structural
        trs.append({"ns": ns, "levers": levers, **({"approx": True} if mode == "approx" else {})})
    conds = [{"check": "/".join(c["vars"]), "sets": "/".join(c["sets"])}
             for c in condition_shapes(n) if c["vars"] or c["sets"]]
    return {"id": cid, "_sha": sha, "region": n.get("regionType"), "combine": combine(n),
            "triggers": trs, "conditions": conds,
            "subRegions": [s.get("type") for s in (n.get("subRegions") or []) if isinstance(s, dict)]}


def cmd_stub(arg):
    """STUB: flatten each aura to WHAT IS TRUE — the live levers in use. SHA-cached per item:
    unchanged auras are SKIPPED on rescan (raw stays in the corpus for debug). `stub all` does the
    whole corpus incrementally; `stub <id>` a single aura/group."""
    corpus, idx, a2, a2_comp, a2_def = _settle_ctx()
    p = os.path.join(OUT, "stubs.json")
    cache = {}
    if os.path.exists(p):
        try:
            cache = {s["id"]: s for s in json.load(open(p, encoding="utf-8")).get("stubs", [])}
        except Exception:
            cache = {}
    allmode = arg in ("all", "--all", "*")
    targets = [k for k, v in corpus.items() if isinstance(v, dict)] if allmode else _ids_for(corpus, arg)
    stubs = dict(cache)                                  # preserve prior; update/add targets
    built = skipped = 0
    changed = []
    for cid in targets:
        n = corpus.get(cid)
        if not isinstance(n, dict):
            continue
        sha = _item_sha(n)
        if cache.get(cid, {}).get("_sha") == sha:        # unchanged -> reuse cached stub
            skipped += 1; continue
        stubs[cid] = _build_stub(cid, n, idx, a2, a2_comp, a2_def, sha)
        built += 1; changed.append(cid)
    os.makedirs(OUT, exist_ok=True)
    json.dump({"stubs": list(stubs.values())}, open(p, "w", encoding="utf-8"), indent=1, ensure_ascii=False)
    for cid in (changed if allmode else targets):        # print freshly-settled (or the targets)
        s = stubs.get(cid)
        if not s:
            continue
        print(f"=== {s['id']}  [{s['region']} · {s['combine']}] ===")
        for tr in s["triggers"]:
            lv = "  ".join(f"{k}={v}" for k, v in tr.get("levers", {}).items()) or "(all defaults)"
            print(f"  {tr['ns']}{' ~approx' if tr.get('approx') else ''}: {lv}")
        if s["conditions"]:
            print("  cond: " + " · ".join(f"{c['check']}→{c['sets']}" for c in s["conditions"]))
    print(f"\n{built} settled, {skipped} skipped (unchanged) — {len(stubs)} stubs in "
          f"{os.path.relpath(p, _ROOT)}. Raw residue stays in the corpus.")


def main():
    argv = sys.argv[1:]
    cmd = argv[0] if argv else "pivot"
    if cmd == "pivot":
        rows = [diagnose_one(s, n) for s, n in pool()]      # fresh crawl on default run
        os.makedirs(OUT, exist_ok=True)
        json.dump(rows, open(os.path.join(OUT, "diagnosis.json"), "w", encoding="utf-8"),
                  indent=1, ensure_ascii=False)
        cmd_pivot(rows)
    elif cmd == "subjects":
        cmd_subjects(load_rows())
    elif cmd == "inspect":
        if len(argv) < 2:
            raise SystemExit("usage: py diagnose.py inspect <#|text>")
        cmd_inspect(load_rows(), " ".join(argv[1:]))
    elif cmd == "lens":
        cmd_lens()
    elif cmd == "settle":
        if len(argv) < 2:
            raise SystemExit("usage: py diagnose.py settle <aura id>")
        cmd_settle(" ".join(argv[1:]))
    elif cmd == "stub":
        if len(argv) < 2:
            raise SystemExit("usage: py diagnose.py stub <aura id>")
        cmd_stub(" ".join(argv[1:]))
    else:
        raise SystemExit(f"unknown command {cmd!r}. use: pivot | subjects | inspect <#|text> | lens | settle <id> | stub <id>")


if __name__ == "__main__":
    main()
