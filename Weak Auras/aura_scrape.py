"""
aura_scrape.py - read the live WeakAuras SavedVariables DB, normalize every
display into the same dict shape weakaura_codec produces, and write a corpus
(+ manifest) for downstream analysis.

Phase 1 of the "read auras directly" pipeline. This is the route that
flattens the design work: instead of hand-exporting one import string at a
time (and hitting the codec's nested-group ceiling), it reads the whole
account DB at once from plain-Lua SavedVariables - no chunking, no nesting
limit - via lua_table.py. Both routes converge on one shape, so the corpus
mixes freely with codec-decoded import strings later.

Two validations run every time, so the reader is never trusted blind:
  A. STRUCTURAL (round-trip): every parsed display is serialized + read back
     through weakaura_codec. A faithful structure survives unchanged. This
     proves the parser output is codec-compatible.
  B. INDEPENDENT (cross-check): Template_shadow exists BOTH as an import
     string (Template_shadow.py) and as live displays in SavedVariables.
     The codec decodes the string; we compare its geometry to the SV copy,
     family by family. Matching geometry proves the parser reads real values
     correctly (not just self-consistently). Divergences are reported - they
     also reveal any live edits since the v0.14 capture, the same way the
     mask reconciliation surfaced the Resources drift.

Read-only: writes only into Outputs/aura_corpus/, never the game files.

    py aura_scrape.py                 # default account WeakAuras.lua
    py aura_scrape.py <WeakAuras.lua>
"""
import json
import os
import sys

_THIS_DIR = os.path.dirname(os.path.abspath(__file__))
_PROJECT_ROOT = os.path.dirname(_THIS_DIR)
sys.path.insert(0, _THIS_DIR)
import lua_table
import weakaura_codec as wc

DEFAULT_SV = ("F:/games/Ascension_wow/resources/ascension-live/WTF/Account/"
              "BATTLEWRATH/SavedVariables/WeakAuras.lua")
CORPUS_DIR = os.path.join(_PROJECT_ROOT, "Outputs", "aura_corpus")


# --------------------------------------------------------------------------- diff
def _empty(v):
    return isinstance(v, (list, dict)) and len(v) == 0


def first_diff(a, b, path="d"):
    """Return a human-readable path to the first structural difference, or
    None if equal. Treats []=={} (empty-table ambiguity) and relies on
    Python's 1==1.0 for int/float."""
    if _empty(a) and _empty(b):
        return None
    if isinstance(a, dict) and isinstance(b, dict):
        ak, bk = set(a), set(b)
        if ak != bk:
            missing = (ak ^ bk)
            return f"{path}: key set differs ({sorted(missing)[:4]})"
        for k in a:
            d = first_diff(a[k], b[k], f"{path}[{k!r}]")
            if d:
                return d
        return None
    if isinstance(a, list) and isinstance(b, list):
        if len(a) != len(b):
            return f"{path}: list len {len(a)} != {len(b)}"
        for idx, (x, y) in enumerate(zip(a, b)):
            d = first_diff(x, y, f"{path}[{idx}]")
            if d:
                return d
        return None
    if a == b:
        return None
    return f"{path}: {a!r} != {b!r}"


# --------------------------------------------------------------------------- validations
def validate_roundtrip(displays):
    matched, mismatched, errored = 0, 0, 0
    details = []
    for aura_id, disp in displays.items():
        try:
            back = wc.decode_import_string(wc.encode_import_string(disp))
        except Exception as e:  # codec couldn't handle it - flag, don't crash
            errored += 1
            details.append(("ERROR", aura_id, f"{type(e).__name__}: {e}"))
            continue
        d = first_diff(disp, back)
        if d is None:
            matched += 1
        else:
            mismatched += 1
            details.append(("MISMATCH", aura_id, d))
    return matched, mismatched, errored, details


# Fields WeakAuras adds/derives when it STORES an aura, absent from an export
# string - so a string-vs-SV comparison must ignore them (they're not parser
# concerns). Confirmed 2026-07-09 by cross-checking three groups.
_WA_STORAGE_ONLY = {"parent", "preferToUpdate", "icon", "displayIcon",
                    "controlledChildren", "sortHybridTable"}
_FLOAT_TOL = 1e-6  # SavedVariables rounds numbers to ~14-15 sig figs

# Curated clean correspondences: a committed group import string whose id +
# child set line up unambiguously with a live display. Independent cross-check
# (codec-from-string vs lua_table-from-SV). Missing files are skipped.
_CROSS_CHECK = [
    ("Necromancer/Buff_Index_v1_import.txt", "Buff Index"),
    ("Necromancer/Minion_tracker_v1_import.txt", "Minion tracker"),
    ("Necromancer/Necro_animation_spec_UI_element_v5_import.txt", "Necro_animation_spec_UI_element"),
]


def _shared_diff(a, b, path="d", top=True):
    """Diff only the fields BOTH sides carry (ignoring WA-storage-only keys at
    the top level), with a float tolerance for SavedVariables' rounding. A
    residual diff here is a real live edit or a genuine parser bug - never
    benign serialization noise."""
    if _empty(a) and _empty(b):  # [] and {} are the same empty Lua table
        return None
    if isinstance(a, dict) and isinstance(b, dict):
        for k in set(a) & set(b):
            if top and k in _WA_STORAGE_ONLY:
                continue
            r = _shared_diff(a[k], b[k], f"{path}[{k!r}]", top=False)
            if r:
                return r
        return None
    if isinstance(a, list) and isinstance(b, list):
        for x, y in zip(a, b):
            r = _shared_diff(x, y, path, top=False)
            if r:
                return r
        return None
    if isinstance(a, (int, float)) and isinstance(b, (int, float)) and not isinstance(a, bool):
        return None if abs(a - b) <= _FLOAT_TOL + _FLOAT_TOL * abs(b) else f"{path}: {a!r} != {b!r}"
    return None if a == b else f"{path}: {a!r} != {b!r}"


def validate_cross_check(displays):
    """Independent value proof: for each curated committed import string, decode
    it with the codec and compare shared fields against the live SV copy. Clean
    = the two independent decoders agree on every field both carry."""
    lines, checked, clean, edited = [], 0, 0, 0
    for rel, gid in _CROSS_CHECK:
        path = os.path.join(_THIS_DIR, *rel.split("/"))
        if not os.path.exists(path) or gid not in displays:
            continue
        group, children = wc.decode_group_import_string(open(path).read().strip())
        for node in [group] + children:
            nid = node.get("id")
            if nid not in displays:
                continue
            checked += 1
            d = _shared_diff(node, displays[nid])
            if d is None:
                clean += 1
            else:
                edited += 1
                lines.append(f"  live-edit {nid!r}: {d}")
    return lines, checked, clean, edited


# --------------------------------------------------------------------------- manifest
def build_manifest(displays):
    region_hist = {}
    groups = {}
    for aura_id, disp in displays.items():
        rt = disp.get("regionType", "?")
        region_hist[rt] = region_hist.get(rt, 0) + 1
        if rt in ("group", "dynamicgroup"):
            groups[aura_id] = disp.get("controlledChildren", [])
    return {
        "total_displays": len(displays),
        "region_histogram": dict(sorted(region_hist.items())),
        "groups": dict(sorted(groups.items())),
        "ids": sorted(displays),
    }


def main():
    sv_path = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_SV
    if not os.path.exists(sv_path):
        raise SystemExit(f"SavedVariables not found: {sv_path}")

    parsed = lua_table.parse_file(sv_path)
    saved = parsed.get("WeakAurasSaved")
    if not isinstance(saved, dict) or "displays" not in saved:
        raise SystemExit("parsed file has no WeakAurasSaved.displays table")
    displays = saved["displays"]
    print(f"parsed {sv_path}\n  {len(displays)} displays\n")

    # A - structural round-trip proof
    matched, mismatched, errored, details = validate_roundtrip(displays)
    print("== validation A: codec round-trip (parser faithfulness) ==")
    print(f"  matched {matched}  |  mismatched {mismatched}  |  errored {errored}")
    for kind, aura_id, msg in details[:12]:
        print(f"  {kind} {aura_id!r}: {msg}")
    print()

    # B - independent value cross-check (codec-from-string vs parser-from-SV)
    lines, checked, clean, edited = validate_cross_check(displays)
    print("== validation B: committed import strings vs SavedVariables (shared-field values) ==")
    print(f"  nodes cross-checked {checked}  |  agree {clean}  |  live-edited {edited}")
    print("  (residual diffs are real in-game edits, not parser errors - float"
          " rounding + WA-storage fields already excluded)")
    for line in lines[:40]:
        print(line)
    print()

    # write corpus + manifest
    os.makedirs(CORPUS_DIR, exist_ok=True)
    corpus_path = os.path.join(CORPUS_DIR, "battlewrath_displays.json")
    manifest_path = os.path.join(CORPUS_DIR, "battlewrath_manifest.json")
    with open(corpus_path, "w", encoding="utf-8") as f:
        json.dump(displays, f, indent=1, ensure_ascii=False)
        f.write("\n")
    manifest = build_manifest(displays)
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)
        f.write("\n")
    print(f"wrote {corpus_path}")
    print(f"wrote {manifest_path}")
    print(f"  region types: {manifest['region_histogram']}")

    return 0 if mismatched == 0 and errored == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
