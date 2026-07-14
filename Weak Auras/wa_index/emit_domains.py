"""
emit_domains.py - the DOMAIN CATALOG: the shared value-domain vocabulary every select/multiselect
lever references, dumped ONCE from Types.lua's `Private.X = {...}` literals (extract.lua `types` mode).

Cross-cutting by nature - `frame_strata_types` serves several regions, `class_types` serves load AND
conditions - so it is ONE shared file referenced by NAME, NOT split per region/type (that would duplicate).
A lever's `value_domain` names a key here; the inventory/pre-flight resolves it by lookup. Over-reported:
flat value->label maps land in `domains`, nested/structural tables in `complex` (kept, not dropped), and
runtime-populated empties (e.g. form_types per class) are listed as a known coa_domains gap.

  py emit_domains.py   -> engine/Fact_basis/sheets/domains.json
"""
import json
import os
import subprocess
import sys

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.normpath(os.path.join(_THIS, "..", ".."))
LUA = os.path.join(_ROOT, ".tools", "lua51", "lua5.1.exe")
EXTRACT = os.path.join(_THIS, "extract.lua")
WA = "F:/games/Ascension_wow/resources/ascension-live/Interface/AddOns/WeakAuras"
TYPES = os.path.join(WA, "Types.lua")
OUT = os.path.join(_THIS, "..", "engine", "Fact_basis", "sheets", "domains.json")

# the aura skeleton, not a value vocabulary
SKIP = {"data_stub"}


def _flat(v):
    """a clean value-domain: a map value->scalar-label, or an array of scalars."""
    if isinstance(v, dict):
        return bool(v) and all(not isinstance(x, (dict, list)) for x in v.values())
    if isinstance(v, list):
        return all(not isinstance(x, (dict, list)) for x in v)
    return False


def main():
    p = subprocess.run([LUA, EXTRACT, "types", TYPES], capture_output=True, text=True)
    if p.returncode != 0:
        sys.exit("extract.lua types failed: " + p.stderr[:400])
    raw = json.loads(p.stdout)

    domains, complex_, empty, skipped = {}, {}, [], []
    for k in sorted(raw):
        v = raw[k]
        if k in SKIP:
            skipped.append(k)
        elif isinstance(v, dict) and not v:
            empty.append(k)                     # runtime-populated (form_types per class, ...) - coa_domains gap
        elif _flat(v):
            domains[k] = v
        else:
            complex_[k] = v                     # nested/structural - kept (over-report), not a clean select domain

    out = {
        "_meta": {
            "source": "extract.lua types Types.lua (Private.X = {...} literals)",
            "note": "shared value-domain catalog; a lever's value_domain NAMES a key in `domains`. "
                    "`complex` = nested tables kept for reference. `empty_runtime` = populated per-class at "
                    "runtime (form_types ...) - a coa_domains gap to fill from the client.",
            "domain_count": len(domains), "complex_count": len(complex_),
            "empty_runtime": empty, "skipped": skipped,
        },
        "domains": domains,
        "complex": complex_,
    }
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, indent=1)
        f.write("\n")
    print("domains -> %s" % os.path.relpath(OUT, _ROOT))
    print("  %d flat domains · %d complex · %d empty(runtime) · %d skipped"
          % (len(domains), len(complex_), len(empty), len(skipped)))
    print("  empty(runtime-populated, coa_domains gap): %s" % empty)


if __name__ == "__main__":
    main()
