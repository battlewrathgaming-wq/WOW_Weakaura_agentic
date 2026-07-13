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
    print("  %-16s -> %2d fields (%s), %d condition-targets"
          % (sheet["region_type"], sheet["option_count"],
             " ".join("%s:%d" % (k, kinds[k]) for k in sorted(kinds)), len(sheet["condition_change_targets"])))


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
                _emit(build(region_name, rd.get("default"), rd.get("properties")))
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
