"""
emit_census.py - the broad declared-surface census of the custom client.

The sheets model (Weak Auras/engine/Fact_basis/sheets) applied to the client:
emit generously, one file per domain + a light routing index, shared catalogs
once, deterministic, provenance-anchored. Contracts then drag out their own
area of interest by READING these tables instead of re-deriving.

Inputs (both produced by sibling tools):
  Outputs/client_interface/patch-B/   the extracted client code (extract_interface.py)
  APIDocumentation (in-client)        the stock 3.3.5 declarations (baseline_extract.lua)

Outputs -> addons/maps/census/ (ALL tracked):
  _meta.json            provenance: archive sha256, counts, grain statement
  baseline.json         stock 3.3.5 declared surface (101 systems: functions/events/tables)
  namespaces/<ns>.json  per C_* namespace: every attested member w/ count + sightings
  namespaces/<ns>.routes.md   the browse line per member
  events.json           every event name seen: how (registered / == compare / custom-prefix
                        string), standing (stock per baseline / custom), sightings
  globals.json          top-level `function Name(` declarations in the shipped UI code,
                        standing vs baseline flat functions
  census.routes.md      the top menu: all namespaces + domain summaries

GRAIN (stated here once, stamped into _meta): this is ATTESTED USAGE from the
shipped UI Lua - evidence of use, not the engine's full export. A C-side
member no UI file touches is invisible here; the runtime census task (pass 3)
is the completeness check. Standing labels lean on the in-client baseline.
"""
import json
import re
import subprocess
import sys
from collections import defaultdict
from datetime import datetime
from pathlib import Path

TOOLS = Path(__file__).resolve().parent
REPO = TOOLS.parents[1]
SRC = REPO / "Outputs" / "client_interface" / "patch-B"
OUT = REPO / "addons" / "maps" / "census"
LUA51 = REPO / ".tools" / "lua51" / "lua5.1.exe"
APIDOC = Path(r"F:\games\Ascension_wow\resources\ascension-live\Interface\AddOns"
              r"\APIDocumentation\Documentation")

SIGHTING_CAP = 8

RE_NS_MEMBER = re.compile(r"\bC_([A-Za-z0-9_]+)[.:]([A-Za-z_][A-Za-z0-9_]*)")
RE_REGISTER = re.compile(r"RegisterEvent\(\s*\"([A-Z0-9_]+)\"")
RE_EVENT_CMP = re.compile(r"event\s*==\s*\"([A-Z0-9_]+)\"")
RE_CUSTOM_STR = re.compile(r"\"((?:ASCENSION|COA)_[A-Z0-9_]+)\"")
RE_GLOBAL_FN = re.compile(r"^function\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(", re.M)


def emit_baseline():
    raw = subprocess.run(
        [str(LUA51), str(TOOLS / "baseline_extract.lua"), str(APIDOC)],
        capture_output=True, text=True, check=True).stdout
    data = json.loads(raw)
    with open(OUT / "baseline.json", "w", encoding="utf-8") as f:
        json.dump(data, f, indent=1, ensure_ascii=False)
    flat_fns = {fn for s in data["systems"] for fn in s["functions"]}
    events = {ev for s in data["systems"] for ev in s["events"]}
    return data, flat_fns, events


def scan_sources():
    """One pass over every extracted code file, collecting all censuses."""
    ns_members = defaultdict(lambda: defaultdict(lambda: {"count": 0, "sightings": []}))
    events = defaultdict(lambda: {"kinds": set(), "count": 0, "sightings": []})
    globals_fn = defaultdict(lambda: {"count": 0, "sightings": []})

    def sight(bucket, where):
        bucket["count"] += 1
        if len(bucket["sightings"]) < SIGHTING_CAP:
            bucket["sightings"].append(where)

    files = sorted(list(SRC.rglob("*.lua")) + list(SRC.rglob("*.xml")))
    for path in files:
        rel = str(path.relative_to(SRC)).replace("\\", "/")
        text = path.read_text(encoding="latin-1")
        for lineno, line in enumerate(text.splitlines(), 1):
            where = f"{rel}:{lineno}"
            for m in RE_NS_MEMBER.finditer(line):
                sight(ns_members["C_" + m.group(1)][m.group(2)], where)
            for m in RE_REGISTER.finditer(line):
                b = events[m.group(1)]
                b["kinds"].add("registered")
                sight(b, where)
            for m in RE_EVENT_CMP.finditer(line):
                b = events[m.group(1)]
                b["kinds"].add("event-compare")
                sight(b, where)
            for m in RE_CUSTOM_STR.finditer(line):
                b = events[m.group(1)]
                b["kinds"].add("custom-prefix-string")
                sight(b, where)
        if path.suffix.lower() == ".lua":
            for m in RE_GLOBAL_FN.finditer(text):
                lineno = text.count("\n", 0, m.start()) + 1
                sight(globals_fn[m.group(1)], f"{rel}:{lineno}")
    return ns_members, events, globals_fn, len(files)


def main():
    if not SRC.is_dir():
        print(f"No extraction at {SRC} - run addons\\tools\\extract_interface.py first")
        sys.exit(2)
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "namespaces").mkdir(exist_ok=True)

    manifest = json.loads((SRC / "manifest.json").read_text(encoding="utf-8"))
    baseline, base_fns, base_events = emit_baseline()
    ns_members, events, globals_fn, files_scanned = scan_sources()

    # namespaces/ - one detail file + one routes line-file per C_* namespace
    for ns in sorted(ns_members):
        members = ns_members[ns]
        detail = {
            "namespace": ns,
            "grain": "attested-usage (shipped UI code); not the engine export",
            "member_count": len(members),
            "members": {name: members[name] for name in sorted(members)},
        }
        with open(OUT / "namespaces" / f"{ns}.json", "w", encoding="utf-8") as f:
            json.dump(detail, f, indent=1, ensure_ascii=False)
        lines = [f"# {ns} - {len(members)} attested members\n"]
        for name in sorted(members):
            m = members[name]
            lines.append(f"- `{name}` x{m['count']} - {m['sightings'][0]}")
        (OUT / "namespaces" / f"{ns}.routes.md").write_text(
            "\n".join(lines) + "\n", encoding="utf-8")

    # events.json - standing from the baseline
    ev_out = {}
    for name in sorted(events):
        e = events[name]
        ev_out[name] = {
            "standing": "stock" if name in base_events else "custom",
            "kinds": sorted(e["kinds"]),
            "count": e["count"],
            "sightings": e["sightings"],
        }
    with open(OUT / "events.json", "w", encoding="utf-8") as f:
        json.dump({
            "grain": "attested in shipped UI code (registered / event-compare / "
                     "custom-prefix string); standing vs in-client APIDocumentation baseline",
            "events": ev_out,
        }, f, indent=1, ensure_ascii=False)

    # globals.json
    gl_out = {}
    for name in sorted(globals_fn):
        g = globals_fn[name]
        gl_out[name] = {
            "standing": "stock-declared" if name in base_fns else "not-in-baseline",
            "count": g["count"],
            "sightings": g["sightings"],
        }
    with open(OUT / "globals.json", "w", encoding="utf-8") as f:
        json.dump({
            "grain": "top-level `function Name(` declarations in the shipped (modified) "
                     "UI code - a MIXTURE of stock and custom; 'not-in-baseline' means "
                     "not a stock C-API name, NOT proven custom (stock FrameXML Lua "
                     "functions aren't in the baseline either)",
            "functions": gl_out,
        }, f, indent=1, ensure_ascii=False)

    # the top routing menu
    ev_custom = sum(1 for e in ev_out.values() if e["standing"] == "custom")
    lines = [
        "# census.routes - the client-surface census (browse menu)\n",
        f"_Anchor: patch-B.MPQ sha256 `{manifest['source_sha256'][:16]}...` | "
        f"emitted {datetime.now().strftime('%Y-%m-%d')} | grain: attested-usage "
        f"(runtime pass corroborates)_\n",
        f"## C_* namespaces ({len(ns_members)}) - open namespaces/<ns>.routes.md",
        "",
    ]
    for ns in sorted(ns_members, key=lambda n: -len(ns_members[n])):
        lines.append(f"- `{ns}` - {len(ns_members[ns])} members")
    lines += [
        "",
        f"## events.json - {len(ev_out)} events ({ev_custom} custom, "
        f"{len(ev_out) - ev_custom} stock-named)",
        f"## globals.json - {len(gl_out)} declared functions",
        f"## baseline.json - stock 3.3.5: {len(base_fns)} functions, "
        f"{len(base_events)} events, {len(baseline['systems'])} systems",
    ]
    (OUT / "census.routes.md").write_text("\n".join(lines) + "\n", encoding="utf-8")

    meta = {
        "emitted_at": datetime.now().isoformat(timespec="seconds"),
        "emitter": "addons/tools/emit_census.py",
        "source_archive": manifest["source"],
        "source_sha256": manifest["source_sha256"],
        "files_scanned": files_scanned,
        "grain": "attested-usage from shipped UI code; the runtime census task is the "
                 "completeness check (a C-side member no UI file calls is invisible here)",
        "counts": {
            "namespaces": len(ns_members),
            "namespace_members": sum(len(v) for v in ns_members.values()),
            "events": len(ev_out),
            "events_custom": ev_custom,
            "global_functions": len(gl_out),
            "baseline_functions": len(base_fns),
            "baseline_events": len(base_events),
        },
    }
    with open(OUT / "_meta.json", "w", encoding="utf-8") as f:
        json.dump(meta, f, indent=1)

    print(f"census emitted -> {OUT.relative_to(REPO)}")
    for k, v in meta["counts"].items():
        print(f"  {k:22} {v}")


if __name__ == "__main__":
    main()
