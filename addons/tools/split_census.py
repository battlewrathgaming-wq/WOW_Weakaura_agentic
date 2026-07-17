"""
split_census.py - the final function attribution, from the loaded/clean record pair.

The single-record reduction (reduce_census.py) left one honest mixture: 1526
'unattributed' functions (user addons were loaded during the walk). The
clean-profile pair settles it by arithmetic:

  user-addon      = loaded - clean            (present only with user addons)
  nameplate-addon = cleanNP - clean           (the isolated Ascension_NamePlates run)
  engine-runtime  = clean - baseline - declared(shipped-ui)
                    (in _G with no addons, not stock-declared, no patch-B call site:
                     engine C-side custom flat API + names built at runtime by shipped code)

Witness records are pinned by runId below (not "newest") - the derivation is
reproducible byte-for-byte. Emits maps/census/runtime/attribution.json.

GRAIN: function names only (widgets are scene-dependent; tables carried as
counts). C_* namespaces proved identical across all three runs - engine-side,
no attribution needed. COA_DevDump v2 was loaded in the clean runs by
necessity; it defines zero global functions (verified), so it cannot pollute.
"""
import json
from datetime import datetime
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
CENSUS = REPO / "addons" / "maps" / "census"
RECORDS = REPO / "addons" / "landing" / "records"
OUT = CENSUS / "runtime"

WITNESSES = {
    "loaded":  "20260715_191602_521__census.json",   # user addons loaded
    "clean":   "20260717_043700_155__census.json",   # everything off (+COA_DevDump)
    "cleanNP": "20260717_043816_464__census.json",   # + Ascension_NamePlates only
}


def fn_set(record_file):
    p = json.loads((RECORDS / record_file).read_text(encoding="utf-8"))["payload"]
    return {k for k, v in p["kinds"].items() if v == "function"}


def main():
    sets = {k: fn_set(f) for k, f in WITNESSES.items()}
    baseline = json.loads((CENSUS / "baseline.json").read_text(encoding="utf-8"))
    base_fns = {fn for s in baseline["systems"] for fn in s["functions"]}
    declared = set(json.loads((CENSUS / "globals.json").read_text(encoding="utf-8"))["functions"])

    user_addon = sorted(sets["loaded"] - sets["clean"])
    nameplate = sorted(sets["cleanNP"] - sets["clean"])
    clean = sets["clean"]
    engine_runtime = sorted(clean - base_fns - declared)
    stock = sorted(clean & base_fns)
    shipped = sorted((clean & declared) - base_fns)

    attribution = {
        "derived_at": datetime.now().isoformat(timespec="seconds"),
        "deriver": "addons/tools/split_census.py",
        "witnesses": WITNESSES,
        "grain": "function globals only; witnesses pinned by runId; namespaces proved "
                 "engine-side (identical across all three runs); COA_DevDump defines no "
                 "global functions and cannot pollute the clean runs. engine-runtime is "
                 "STILL a compound: true engine/Ascension customs PLUS un-overridden STOCK "
                 "FrameXML Lua (patch-B replaces only part of FrameXML, so stock files' "
                 "functions have no declared witness) - a stock-FrameXML function list is "
                 "the refinement that would split it, if ever needed",
        "counts": {
            "stock-capi": len(stock),
            "shipped-ui": len(shipped),
            "engine-runtime": len(engine_runtime),
            "user-addon": len(user_addon),
            "nameplate-addon": len(nameplate),
        },
        "buckets": {
            "engine-runtime": engine_runtime,
            "user-addon": user_addon,
            "nameplate-addon": nameplate,
        },
    }
    with open(OUT / "attribution.json", "w", encoding="utf-8") as f:
        json.dump(attribution, f, indent=1, ensure_ascii=False)

    print(f"attribution -> {OUT.relative_to(REPO)}\\attribution.json")
    for k, v in attribution["counts"].items():
        print(f"  {k:16} {v}")


if __name__ == "__main__":
    main()
