"""
emit_display_sheet.py - the DISPLAY domain state sheets (sibling to emit_state_sheet.py's trigger domain).
Per region type: the DECLARABLE surface (fields + observed defaults) AND the condition CHANGE-targets
(properties). Sourced from extract.lua `region` mode = WA's own RegisterRegionType `default` + GetProperties.

The region `default` IS the observed-defaults resource for display (matches canon exactly); the `properties`
are the "changes" side of a condition-join. Position fields (xOffset/anchor...) are flagged mask-territory -
they're reduced from the inventory's slot-ref, not authored per aura.

  py emit_display_sheet.py            -> statesheets/display/<region>.json for every region type
  py emit_display_sheet.py icon
"""
import glob
import json
import os
import subprocess
import sys

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.normpath(os.path.join(_THIS, "..", ".."))
LUA = os.path.join(_ROOT, ".tools", "lua51", "lua5.1.exe")
EXTRACT = os.path.join(_THIS, "extract.lua")
REGIONS = "F:/games/Ascension_wow/resources/ascension-live/Interface/AddOns/WeakAuras/RegionTypes"
OUTDIR = os.path.join(_THIS, "statesheets", "display")

POSITION = {"xOffset", "yOffset", "anchorPoint", "selfPoint", "anchorFrameType", "frameStrata"}
SIZE = {"width", "height"}
REGIONPROTO = os.path.join(REGIONS, "RegionPrototype.lua")
ACTION_TYPES = {"chat", "customcode", "glowexternal", "sound"}   # condition side-effects, not property-changes
REGION_OPTIONS = "F:/games/Ascension_wow/resources/ascension-live/Interface/AddOns/WeakAurasOptions/RegionOptions"
# region types whose OWN options surface (arrangement/config levers) we fold in. group + dynamicgroup are FIRST-CLASS:
# their arrangement behaviour over children IS authored content, so it needs trigger-grade detail. Other regions author
# their look via the mask (reduced from the slot-ref), not here - not pre-generalized past the group need.
OPTION_SURFACE_FILES = {"group": "Group.lua", "dynamicgroup": "DynamicGroup.lua"}
_CHROME_TYPES = {"header", "description", "execute"}             # options-table UI chrome, not configurable levers


def _region(path):
    proc = subprocess.run([LUA, EXTRACT, "region", path], capture_output=True, text=True)
    if proc.returncode != 0:
        return None
    try:
        return json.loads(proc.stdout)
    except Exception:
        return None


def build(region_name, default, properties):
    targets = set((properties or {}).keys())          # GetProperties keys = condition change-targets
    options = []
    for name in sorted(default or {}):
        kind = "size" if name in SIZE else ("position" if name in POSITION else "option")
        options.append({"name": name, "default": default[name],
                        "condition_target": name in targets, "kind": kind})
    return {
        "domain": "display", "region_type": region_name, "option_count": len(options),
        "options": options,
        "condition_change_targets": sorted(targets),   # the "changes" side of a condition-join
        "_meta": {"source": "extract.lua region -> WA's RegisterRegionType default + GetProperties. The default IS "
                            "the observed-defaults resource (matches canon); properties = condition change-targets. "
                            "kind=position fields are mask-territory (reduced from the inventory slot-ref, not authored)."},
    }


def _options_surface(region_name, default):
    """A region's OWN options surface (the config levers WA's UI exposes for it) via extract.lua regionoptionsurface.
    The per-region DEFAULT gives field VALUES; this gives each lever's TYPE + value-domain + conditional-visibility -
    the trigger-grade detail the default alone misses (the group-arrangement blind spot). Merges the default value in.
    conditional=True marks a context-gated lever (e.g. grid levers only apply under GRID grow) - WA's own visibility rule."""
    fname = OPTION_SURFACE_FILES.get(region_name)
    if not fname:
        return None
    proc = subprocess.run([LUA, EXTRACT, "regionoptionsurface",
                           os.path.join(REGION_OPTIONS, fname), region_name], capture_output=True, text=True)
    if proc.returncode != 0:
        return None
    try:
        raw = json.loads(proc.stdout)
    except Exception:
        return None
    levers = {}
    for name, o in raw.items():
        if o.get("type") in _CHROME_TYPES:                 # drop header/description/execute UI chrome
            continue
        rec = {"type": o.get("type"), "name": o.get("name"), "order": o.get("order")}
        if "values" in o:
            rec["values"] = o["values"]                    # value-domain (str -> domains.json) or an inline table
        for b in ("min", "max", "step", "softMin", "softMax", "bigStep"):
            if b in o:
                rec[b] = o[b]                              # numeric bounds for range levers - the numeric value-domain
        if o.get("conditional"):
            rec["conditional"] = True                      # context-gated visibility (grow-mode dependent, etc.)
        if isinstance(default, dict) and name in default:
            rec["default"] = default[name]                 # merge the region-default value for this lever
        levers[name] = rec
    return {"lever_count": len(levers), "levers": levers,
            "_meta": {"source": "extract.lua regionoptionsurface -> RegisterRegionOptions create(id,data). The "
                                "configurable arrangement surface (type + value-domain + conditional) the per-region "
                                "default misses. conditional = context-gated (grow-mode dependent). chrome dropped."}}


def _coupling(region_name):
    """The grow/gridType -> selfPoint DERIVATION table (dynamicgroup only), generated by RUNNING WA's set logic.
    selfPoint is coupled to grow(+align)/gridType in the options set functions; the region reads data.selfPoint
    DIRECTLY and never re-derives it, so an authored grow needs its paired selfPoint. The expander injects it from
    here -> any grow is shippable. GENERATED not hand-built: inputs enumerated, outputs are WA's own set closure."""
    if region_name != "dynamicgroup":
        return None
    proc = subprocess.run([LUA, EXTRACT, "regioncoupling",
                           os.path.join(REGION_OPTIONS, "DynamicGroup.lua"), region_name], capture_output=True, text=True)
    if proc.returncode != 0:
        return None
    try:
        raw = json.loads(proc.stdout)
    except Exception:
        return None
    if not raw.get("by_grow_align"):
        return None
    return {"derives": "selfPoint", "from": ["grow", "align", "gridType"],
            "by_grow_align": raw["by_grow_align"], "by_gridtype": raw["by_gridtype"],
            "_meta": {"source": "extract.lua regioncoupling -> WA's grow-lever set closure (selfPoints/gridSelfPoints "
                                "upvalues = the real tables). The region reads data.selfPoint directly (never re-derives), "
                                "so an authored grow needs its paired selfPoint; the expander injects it from here. "
                                "Generated (inputs enumerated, outputs are WA's), not hand-built."}}


def _routes(sheet):
    """ROUTING INDEX (light MD) for a region: the authorable display levers (kind=option; position/size are
    mask-territory, reduced from the slot-ref, omitted here), one line each -> open <region>.json for full
    defaults/detail. `chg` marks a condition change-target. The browse-menu; read detail on demand."""
    rn = sheet.get("region_type")
    out = ["# %s - routing index" % rn,
           "_Authorable display levers (position/size = mask-territory, omitted). Open `%s.json` for all "
           "fields + defaults. `chg` = a condition change-target._" % rn,
           "| lever | default | chg |", "|---|---|---|"]
    for o in sheet.get("options", []):
        if o.get("kind") != "option":
            continue
        d = o.get("default")
        out.append("| %s | %s | %s |" % (o.get("name"), "" if d is None else d,
                                         "Y" if o.get("condition_target") else ""))
    return "\n".join(out) + "\n"


def _emit(sheet):
    os.makedirs(OUTDIR, exist_ok=True)
    with open(os.path.join(OUTDIR, sheet["region_type"] + ".json"), "w", encoding="utf-8") as f:
        json.dump(sheet, f, ensure_ascii=False, indent=1)
        f.write("\n")
    with open(os.path.join(OUTDIR, sheet["region_type"] + ".routes.md"), "w", encoding="utf-8") as f:
        f.write(_routes(sheet))
    kinds = {}
    for o in sheet["options"]:
        kinds[o["kind"]] = kinds.get(o["kind"], 0) + 1
    surf = sheet.get("option_surface")
    print("  %-16s -> %2d fields (%s), %d condition-targets%s"
          % (sheet["region_type"], sheet["option_count"],
             " ".join("%s:%d" % (k, kinds[k]) for k in sorted(kinds)), len(sheet["condition_change_targets"]),
             (" + %d option-surface levers" % surf["lever_count"]) if surf else ""))


def _shared():
    """The regionPrototype SHARED layer (RegionPrototype.AddProperties): change-targets EVERY region inherits.
    Cross-cutting, so emitted ONCE (like domains.json), never duplicated per region. Split: property-changes
    (the relative offsets) vs condition ACTIONS (chat/sound/customcode/glowexternal - side-effects, a distinct
    'Then' category). This is the layer the per-region default+GetProperties misses; folding it in closes the
    change-target completeness gap (so we stop re-discovering these by round-tripping dockets)."""
    proc = subprocess.run([LUA, EXTRACT, "regionprototype", REGIONPROTO], capture_output=True, text=True)
    if proc.returncode != 0:
        return None
    sp = (json.loads(proc.stdout).get("shared_properties")) or {}
    changes, actions, records = [], [], {}
    for name in sorted(sp):
        rec = sp[name]
        ty = rec.get("type") if isinstance(rec, dict) else None
        (actions if ty in ACTION_TYPES else changes).append(name)
        records[name] = {"type": ty, "display": rec.get("display") if isinstance(rec, dict) else None}
    return {"domain": "display", "layer": "regionPrototype.AddProperties (inherited by EVERY region)",
            "shared_change_targets": changes, "condition_actions": actions, "records": records,
            "_meta": {"source": "extract.lua regionprototype -> RegionPrototype.AddProperties. Cross-cutting: the "
                              "contract UNIONs these into each region's change_targets. actions = condition "
                              "side-effects (a distinct 'Then' category). shared_defaults empty under stubs (TODO)."}}


def main():
    want = sys.argv[1] if len(sys.argv) > 1 else None
    print("display domain -> %s/" % os.path.relpath(OUTDIR, _ROOT))
    for path in sorted(glob.glob(os.path.join(REGIONS, "*.lua"))):
        data = _region(path)
        if not data:
            continue
        for region_name, rd in data.items():
            if want and region_name != want:
                continue
            if isinstance(rd, dict) and isinstance(rd.get("default"), dict):
                sheet = build(region_name, rd.get("default"), rd.get("properties"))
                surf = _options_surface(region_name, rd.get("default"))
                if surf:
                    sheet["option_surface"] = surf         # group/dynamicgroup: their arrangement levers, trigger-grade
                cpl = _coupling(region_name)
                if cpl:
                    sheet["coupling"] = cpl                 # dynamicgroup: grow/gridType -> selfPoint derivation table
                _emit(sheet)
    if not want:                                          # the cross-cutting shared layer, once
        sh = _shared()
        if sh:
            os.makedirs(OUTDIR, exist_ok=True)
            with open(os.path.join(OUTDIR, "_shared.json"), "w", encoding="utf-8") as f:
                json.dump(sh, f, ensure_ascii=False, indent=1)
                f.write("\n")
            print("  %-16s -> _shared.json (%d change-targets, %d actions)"
                  % ("(shared layer)", len(sh["shared_change_targets"]), len(sh["condition_actions"])))


if __name__ == "__main__":
    main()
