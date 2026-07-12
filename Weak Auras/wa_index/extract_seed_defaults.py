"""
extract_seed_defaults.py - freeze WA's function-driven trigger defaults into a referenced table,
and PROBE new sources for more.

The arg-scan (build_index.py) captures each prototype's *declared* arg defaults but misses the seeds
set in `init` code (`trigger.X = trigger.X or <default>`). This runs `init` on an EMPTY trigger headless
(via extract.lua) and captures the scalars it writes back - WA's own code producing its own defaults.

  py extract_seed_defaults.py                    FREEZE: extract Prototypes.lua event_prototypes,
                                                 validate against anchors, write trigger_seed_defaults.json
  py extract_seed_defaults.py probe <file> [mode]  PROBE (read-only): run extract.lua on a WA source file
                                                 (relative to the WA addon dir) and PRINT the raw result.
                                                 Default mode = seed_defaults. For discovering new sources.

Same source->extraction->anchor-validated-table topology as extract_spell_dbc.py (different feeding pack).
Re-run FREEZE only when WA source changes; the table is the durable artifact. PROBE is for discovery.
"""
import json
import os
import subprocess
import sys

_THIS = os.path.dirname(os.path.abspath(__file__))
LUA = os.path.normpath(os.path.join(_THIS, "..", "..", ".tools", "lua51", "lua5.1.exe"))
EXTRACT = os.path.join(_THIS, "extract.lua")
WA = "F:/games/Ascension_wow/resources/ascension-live/Interface/AddOns/WeakAuras"
OUT = os.path.join(_THIS, "trigger_seed_defaults.json")

# anchors: known-good values the FREEZE must reproduce (its own drift guard). player + target
# families, so a blanket bug can't pass.
_EXPECT = {"Power": {"unit": "player"}, "Health": {"unit": "player"},
           "Range Check": {"unit": "target"}, "Threat Situation": {"unit": "target"},
           "aura2": {"unit": "player", "debuffType": "HELPFUL"}}


def _run(mode, path):
    proc = subprocess.run([LUA, EXTRACT, mode, path], capture_output=True, text=True)
    if proc.returncode != 0:
        raise SystemExit("extract failed (%s %s): %s" % (mode, os.path.basename(path), proc.stderr.strip()))
    return json.loads(proc.stdout)


def cmd_freeze():
    raw = _run("seed_defaults", os.path.join(WA, "Prototypes.lua"))
    table = {k: v["seeds"] for k, v in raw.items() if isinstance(v, dict) and v.get("seeds")}
    # aura2 seeds via BuffTrigger2's trigger-system Add(), not an event_prototype - separate probe
    aura = _run("aura_seed_defaults", os.path.join(WA, "BuffTrigger2.lua"))
    if isinstance(aura.get("aura2"), dict) and aura["aura2"].get("seeds"):
        table["aura2"] = aura["aura2"]["seeds"]
    for ev, exp in _EXPECT.items():
        got = table.get(ev, {})
        for field, val in exp.items():
            if got.get(field) != val:
                raise SystemExit("VALIDATION FAILED: %s.%s expected %r, got %r"
                                 % (ev, field, val, got.get(field)))
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(table, f, indent=1, sort_keys=True, ensure_ascii=False)
        f.write("\n")
    print("froze %d prototype seed-default sets -> %s (anchors: %s)"
          % (len(table), os.path.basename(OUT), ", ".join(sorted(_EXPECT))))


def cmd_probe(fname, mode="seed_defaults"):
    if ".." in fname or os.path.isabs(fname):          # keep probes inside the WA addon dir
        raise SystemExit("probe target must be a filename/subpath inside the WA addon dir")
    path = os.path.join(WA, fname)
    print("# probe: extract.lua %s %s" % (mode, fname))
    print(json.dumps(_run(mode, path), indent=1, sort_keys=True, ensure_ascii=False))


def main():
    args = sys.argv[1:]
    if args and args[0] == "probe":
        if len(args) < 2:
            raise SystemExit("usage: extract_seed_defaults.py probe <wa-source-file> [extract-mode]")
        cmd_probe(args[1], args[2] if len(args) > 2 else "seed_defaults")
    else:
        cmd_freeze()


if __name__ == "__main__":
    main()
