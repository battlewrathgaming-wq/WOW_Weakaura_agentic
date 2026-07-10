"""
diff.py - the verdict tool. Compares our pipeline-assembled table against a REAL
aura Battlewrath hand-builds in-game, read fresh from the live SavedVariables.
A clean diff means the dumb assembler reproduced what a human would build.

Ignores, deliberately:
  - position (xOffset/yOffset/anchor*) - out of MVP scope, hand-build will differ
  - WA storage-only fields + float rounding - via aura_scrape's _shared_diff
Compares only fields BOTH sides carry (a residual diff is a real shape mismatch).

    py diff.py <our_table.json> "<hand-built display id>"
    py diff.py out/corpse_explosion_availability.table.json "Corpse Explosion Availability"
"""
import json
import os
import sys

_THIS = os.path.dirname(os.path.abspath(__file__))
_WEAKAURAS = os.path.dirname(_THIS)
sys.path.insert(0, _WEAKAURAS)
import lua_table
import aura_scrape

_TOL = aura_scrape._FLOAT_TOL
# Ignored at the TOP level only: position (out of scope), identity (minted per
# build), and WA storage-only fields (WA re-derives on store). Everything nested
# (trigger bodies, load block, subRegions) is compared in full - that's where
# the leftover-field question lives.
_IGNORE_TOP = ({"xOffset", "yOffset", "anchorPoint", "selfPoint",
                "anchorFrameType", "id", "uid"} | aura_scrape._WA_STORAGE_ONLY)


def _empty(v):
    return isinstance(v, (list, dict)) and len(v) == 0


def deep_diff(a, b, path="d", ignore=frozenset(), out=None):
    """Full recursive diff. Reports value mismatches AND key-presence diffs at
    every level. Normalizes dict-key types (JSON str '1' vs Lua int 1), treats
    []=={} , is float-tolerant, and compares booleans by identity (not 1==True).
    `ignore` applies only at the level it's passed (top)."""
    if out is None:
        out = []
    if _empty(a) and _empty(b):
        return out
    if isinstance(a, dict) and isinstance(b, dict):
        A = {str(k): v for k, v in a.items()}
        B = {str(k): v for k, v in b.items()}
        ak, bk = set(A), set(B)
        for k in sorted((ak - bk) - ignore):
            out.append(f"{path}: OURS-ONLY key {k!r} = {json.dumps(A[k], ensure_ascii=False)[:70]}")
        for k in sorted((bk - ak) - ignore):
            out.append(f"{path}: THEIRS-ONLY key {k!r} = {json.dumps(B[k], ensure_ascii=False)[:70]}")
        for k in sorted((ak & bk) - ignore):
            deep_diff(A[k], B[k], f"{path}[{k!r}]", frozenset(), out)
        return out
    if isinstance(a, list) and isinstance(b, list):
        if len(a) != len(b):
            out.append(f"{path}: list len {len(a)} != {len(b)}")
            return out
        for i, (x, y) in enumerate(zip(a, b)):
            deep_diff(x, y, f"{path}[{i}]", frozenset(), out)
        return out
    if (isinstance(a, (int, float)) and isinstance(b, (int, float))
            and not isinstance(a, bool) and not isinstance(b, bool)):
        if abs(a - b) <= _TOL + _TOL * abs(b):
            return out
        out.append(f"{path}: {a!r} != {b!r}")
        return out
    if a != b:
        out.append(f"{path}: {a!r} != {b!r}")
    return out


def main():
    if len(sys.argv) < 3:
        raise SystemExit('usage: py diff.py <our_table.json> "<hand-built display id>"')
    table_path, display_id = sys.argv[1], sys.argv[2]
    ours = json.load(open(table_path, encoding="utf-8"))

    sv = aura_scrape.DEFAULT_SV
    if not os.path.exists(sv):
        raise SystemExit(f"SavedVariables not found: {sv}")
    displays = lua_table.parse_file(sv).get("WeakAurasSaved", {}).get("displays", {})
    if display_id not in displays:
        cand = [k for k in displays if display_id.lower() in k.lower()]
        raise SystemExit(f"{display_id!r} not in live SavedVariables. Close matches: {cand[:8]}")
    theirs = displays[display_id]

    diffs = deep_diff(ours, theirs, "d", _IGNORE_TOP)
    print(f"diffing OUR {os.path.basename(table_path)}  vs  LIVE {display_id!r}")
    print(f"  (ignoring position/identity + WA storage-only at top level; float-tolerant)\n")
    if not diffs:
        print("  CLEAN - every field matches (values + presence). Pipeline reproduces the hand-build.")
        return 0
    for d in diffs:
        print(f"  {d}")
    print(f"\n  {len(diffs)} difference(s).")
    return 1


if __name__ == "__main__":
    sys.exit(main())
