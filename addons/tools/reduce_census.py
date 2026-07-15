"""
reduce_census.py - join the three census witnesses into the first-goal tables.

Witnesses:
  RUNTIME  the landed `census` task record (the definitive _G walk)
  DECLARED addons/maps/census/namespaces/ + globals.json (attested shipped-UI usage)
  BASELINE addons/maps/census/baseline.json (stock 3.3.5, from the client's own
           APIDocumentation)

Outputs -> addons/maps/census/runtime/ (tracked):
  namespaces.json   every runtime C_* namespace: members typed + standing
                    (attested = shipped UI calls it / runtime-only = exists but
                    no shipped call site - the surface the declared pass can't
                    see). Plus declared-only members/namespaces (attested in
                    code but absent from this runtime - conditional/glue-only).
  globals.json      every runtime FUNCTION global bucketed: stock-capi (in
                    baseline) / shipped-ui (declared in patch-B code) /
                    unattributed (engine C-side custom OR user-addon - this
                    run had the user's addons loaded; see grain).
  runtime.routes.md the browse summary.

GRAIN: the runtime record was captured on a logged-in character WITH user
addons loaded (WeakAuras etc.), so `unattributed` is a MIXTURE until a
clean-profile run (addons disabled at character select) splits engine-custom
from user-addon. The C_* namespace tables are effectively pollution-free
(user addons don't mint C_* namespaces). Record's runId is the anchor.

Usage: py addons\\tools\\reduce_census.py [record.json]   (default: newest census record)
"""
import json
import sys
from datetime import datetime
from pathlib import Path

TOOLS = Path(__file__).resolve().parent
REPO = TOOLS.parents[1]
CENSUS = REPO / "addons" / "maps" / "census"
RECORDS = REPO / "addons" / "landing" / "records"
OUT = CENSUS / "runtime"


def newest_census_record():
    cands = sorted(RECORDS.glob("*__census.json"))
    if not cands:
        print("No census record in addons/landing/records/ - run the census task first.")
        sys.exit(2)
    return cands[-1]


def main():
    record_path = Path(sys.argv[1]) if len(sys.argv) > 1 else newest_census_record()
    record = json.loads(record_path.read_text(encoding="utf-8"))
    header, payload = record["header"], record["payload"]

    baseline = json.loads((CENSUS / "baseline.json").read_text(encoding="utf-8"))
    base_fns = {fn for s in baseline["systems"] for fn in s["functions"]}
    declared_globals = json.loads((CENSUS / "globals.json").read_text(encoding="utf-8"))["functions"]

    declared_ns = {}
    for f in (CENSUS / "namespaces").glob("C_*.json"):
        d = json.loads(f.read_text(encoding="utf-8"))
        declared_ns[d["namespace"]] = set(d["members"])

    OUT.mkdir(exist_ok=True)

    # ---- namespaces: runtime x declared ----
    runtime_ns = payload["ns"]
    ns_out, totals = {}, {"attested": 0, "runtime_only": 0, "declared_only": 0}
    for ns in sorted(runtime_ns):
        members = runtime_ns[ns]
        attested = declared_ns.get(ns, set())
        entry = {"standing": "attested-ns" if ns in declared_ns else "runtime-only-ns",
                 "members": {}}
        for name in sorted(members):
            standing = "attested" if name in attested else "runtime-only"
            totals["attested" if standing == "attested" else "runtime_only"] += 1
            entry["members"][name] = {"type": members[name], "standing": standing}
        gone = sorted(attested - set(members))
        if gone:
            entry["declared_only_members"] = gone
            totals["declared_only"] += len(gone)
        ns_out[ns] = entry
    declared_only_ns = sorted(set(declared_ns) - set(runtime_ns))

    with open(OUT / "namespaces.json", "w", encoding="utf-8") as f:
        json.dump({
            "grain": "runtime = the definitive existence witness; 'runtime-only' members "
                     "have NO shipped-UI call site (invisible to the declared pass); "
                     "'declared_only' entries were attested in code but absent this runtime "
                     "(conditional/glue-context). C_* tables are effectively user-addon-free.",
            "record": record_path.name,
            "runId": header["runId"],
            "declared_only_namespaces": declared_only_ns,
            "totals": totals,
            "namespaces": ns_out,
        }, f, indent=1, ensure_ascii=False)

    # ---- flat globals: bucket every runtime function ----
    kinds = payload["kinds"]
    buckets = {"stock-capi": [], "shipped-ui": [], "unattributed": []}
    for name in sorted(kinds):
        if kinds[name] != "function":
            continue
        if name in base_fns:
            buckets["stock-capi"].append(name)
        elif name in declared_globals:
            buckets["shipped-ui"].append(name)
        else:
            buckets["unattributed"].append(name)
    with open(OUT / "globals.json", "w", encoding="utf-8") as f:
        json.dump({
            "grain": "every runtime FUNCTION global. unattributed = engine C-side custom OR "
                     "user-addon (this run had user addons loaded) OR stock FrameXML-only - "
                     "a clean-profile capture splits it. stock-capi = in the APIDocumentation "
                     "baseline; shipped-ui = declared in patch-B code.",
            "record": record_path.name,
            "runId": header["runId"],
            "counts": {k: len(v) for k, v in buckets.items()},
            "functions": buckets,
        }, f, indent=1, ensure_ascii=False)

    # ---- the browse summary ----
    biggest_gap = sorted(
        ((ns, sum(1 for m in e["members"].values() if m["standing"] == "runtime-only"))
         for ns, e in ns_out.items()), key=lambda x: -x[1])
    lines = [
        "# runtime.routes - the runtime census reduction (pass 3 joined to the witnesses)\n",
        f"_Record `{record_path.name}` (runId {header['runId']}, {header['char']}/"
        f"{header['class']}) | reduced {datetime.now().strftime('%Y-%m-%d')}_\n",
        f"- runtime globals: {payload['total']} ({payload['functions']} functions / "
        f"{payload['tables']} tables / {payload['widgets']} widgets)",
        f"- C_* namespaces at runtime: {len(ns_out)} "
        f"(+{len(declared_only_ns)} declared-only: {', '.join(declared_only_ns) or 'none'})",
        f"- namespace members: {totals['attested']} attested + "
        f"{totals['runtime_only']} RUNTIME-ONLY (the surface shipped code never calls) + "
        f"{totals['declared_only']} declared-only",
        f"- flat functions: {len(buckets['stock-capi'])} stock-capi / "
        f"{len(buckets['shipped-ui'])} shipped-ui / {len(buckets['unattributed'])} "
        f"unattributed (mixture - see grain)",
        "",
        "## Biggest runtime-only surfaces (uncalled API = pure discovery)",
        "",
    ]
    for ns, n in biggest_gap[:15]:
        if n:
            lines.append(f"- `{ns}` - {n} runtime-only members "
                         f"(of {len(ns_out[ns]['members'])})")
    (OUT / "runtime.routes.md").write_text("\n".join(lines) + "\n", encoding="utf-8")

    print(f"reduced -> {OUT.relative_to(REPO)}")
    print(f"  namespaces: {len(ns_out)} runtime ({len(declared_only_ns)} declared-only)")
    print(f"  members: {totals['attested']} attested / {totals['runtime_only']} runtime-only "
          f"/ {totals['declared_only']} declared-only")
    print(f"  functions: {len(buckets['stock-capi'])} stock / {len(buckets['shipped-ui'])} "
          f"shipped-ui / {len(buckets['unattributed'])} unattributed")


if __name__ == "__main__":
    main()
