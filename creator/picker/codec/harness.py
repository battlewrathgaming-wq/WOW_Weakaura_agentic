"""harness.py - Phase 1 cross-validation: the JS encoder vs the live-proven Python codec.

For every vector (synthetic edge cases + REAL pressed packs from Docket_complete):
    python string = "!WA:2!" + encode_for_print(compress_deflate(serialize(value)))
    js string     = node wa_encode.mjs  (same value, via the __luaMap__-marked JSON mirror)
    decode BOTH with the existing decoder -> the tables must be DEEP-EQUAL.

DECODE-EQUIVALENCE is the criterion, never string bytes: DEFLATE output and map-part
ordering legitimately vary per implementation; what must not vary is the table WA sees.

    py harness.py            -> full run (synthetics + all packs), receipt printed
    py harness.py --packs 5  -> synthetics + a 5-pack sample
"""
import json
import os
import subprocess
import sys

_HERE = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.abspath(os.path.join(_HERE, "..", "..", ".."))
sys.path.insert(0, os.path.join(_ROOT, "Weak Auras"))
import weakaura_codec as wc  # noqa: E402

_PACKS = os.path.join(_ROOT, "Weak Auras", "engine", "Production", "Docket_complete")
_NODE_SCRIPT = os.path.join(_HERE, "wa_encode.mjs")


# ---------------------------------------------------------------- the JSON mirror
def lua_to_json(v):
    """Convert a decoded Lua-typed Python value into the JSON form wa_encode.mjs
    understands: int-keyed dicts become string-keyed with "__luaMap__": true.
    (A contiguous 1..N int-keyed dict and a JSON array serialize identically in
    LibSerialize, so marking is sufficient - no array conversion needed here.)"""
    if isinstance(v, list):
        return [lua_to_json(x) for x in v]
    if isinstance(v, dict):
        has_int = any(isinstance(k, int) for k in v)
        out = {}
        if has_int:
            out["__luaMap__"] = True
        for k, val in v.items():
            if isinstance(k, bool) or not isinstance(k, (int, str)):
                raise TypeError(f"unsupported table key for the mirror: {k!r}")
            out[str(k)] = lua_to_json(val)
        return out
    return v


# ---------------------------------------------------------------- vectors
def synthetic_vectors():
    """The codec's known edge classes, each as a top-level value."""
    return {
        "small ints + bools + nil": {"a": 0, "b": 127, "c": 128, "d": -1, "e": True, "f": False, "g": None},
        "12-bit boundaries": {"lo": -4095, "hi": 4095, "past_lo": -4096, "past_hi": 4096},
        "wide ints": {"w2": 65535, "w3": 16777215, "w4": 4294967295, "w7": 2 ** 40, "neg": -(2 ** 33)},
        "floats floatstr + ieee": {"half": 0.5, "tenth": 0.1, "long": 0.30000000000000004,
                                   "neg": -2.25, "ieee_long": 123456.789},
        "multiline custom code (findings #8 class)": {
            "custom": "function(allstates, event, ...)\n  local x = \"quoted\"\n\tallstates[''] = {show = true}\n  return true\nend",
        },
        "string refs (repeats > 2 chars)": {"x": "spellName", "y": "spellName", "z": ["spellName", "ab", "ab"]},
        "long string >16": {"s": "A" * 250, "s2": "B" * 70000},
        "empty tables": {"e1": {}, "e2": [], "nested": {"deep": {}}},
        "arrays + mixed": {"arr": [1, 2, 3], "mixed_src": {"__luaMap__": True, "1": "one", "2": "two", "name": "m"}},
        "int-keyed map non-contiguous": {"multi": {"__luaMap__": True, "1": True, "3": True}},
        "unicode": {"u": "Fläche → 魔法 — ok"},
    }


def json_form_to_lua(v):
    """The python-side reading of the JSON mirror (so python encodes the SAME value
    the JS sees when a vector is authored directly in mirror form)."""
    if isinstance(v, list):
        return [json_form_to_lua(x) for x in v]
    if isinstance(v, dict):
        is_map = v.get("__luaMap__") is True
        out = {}
        for k, val in v.items():
            if k == "__luaMap__":
                continue
            key = int(k) if (is_map and k.lstrip("-").isdigit()) else k
            out[key] = json_form_to_lua(val)
        return out
    return v


def pack_vectors(limit=None):
    """REAL products: decode every pressed pack's import string to its raw envelope."""
    out = {}
    files = sorted(f for f in os.listdir(_PACKS) if f.endswith(".txt"))
    if limit:
        files = files[:limit]
    for f in files:
        s = open(os.path.join(_PACKS, f), encoding="utf-8").read().strip()
        out[f] = wc.decode_import_string_raw(s)
    return out


def norm(v):
    """Comparison form: an empty Lua table has no array/map identity ({} == [] on
    the Lua side - the round-trip verifier's registered class), so canonicalize
    every empty container to {} before deep-comparing."""
    if isinstance(v, list):
        return {} if not v else [norm(x) for x in v]
    if isinstance(v, dict):
        return {k: norm(val) for k, val in v.items()}
    return v


# ---------------------------------------------------------------- the run
def py_encode(value):
    return f"!WA:{wc.WA_ENCODE_VERSION}!" + wc.encode_for_print(
        wc.compress_deflate(wc.serialize(value)))


def js_encode_batch(json_lines):
    r = subprocess.run(["node", _NODE_SCRIPT], input="\n".join(json_lines),
                       capture_output=True, text=True, encoding="utf-8")
    if r.returncode != 0:
        raise RuntimeError(f"node failed:\n{r.stderr}")
    return r.stdout.strip().split("\n")


def main():
    limit = None
    if "--packs" in sys.argv:
        limit = int(sys.argv[sys.argv.index("--packs") + 1])

    vectors = {}
    for name, mirror in synthetic_vectors().items():
        vectors[name] = (json_form_to_lua(mirror), mirror)
    for name, lua in pack_vectors(limit).items():
        vectors[name] = (lua, lua_to_json(lua))

    names = list(vectors)
    js_lines = [json.dumps(vectors[n][1], ensure_ascii=False, separators=(",", ":")) for n in names]
    js_strings = js_encode_batch(js_lines)
    assert len(js_strings) == len(names), f"line count mismatch: {len(js_strings)} vs {len(names)}"

    ok = bad = 0
    for name, js_s in zip(names, js_strings):
        lua_value = vectors[name][0]
        py_s = py_encode(lua_value)
        py_back = norm(wc.decode_import_string_raw(py_s))
        js_back = norm(wc.decode_import_string_raw(js_s))
        lua_value = norm(lua_value)
        if py_back == js_back and py_back == lua_value:
            ok += 1
        else:
            bad += 1
            print(f"MISMATCH: {name}")
            if py_back != lua_value:
                print("  python round-trip broke (codec-side, investigate first)")
            if py_back != js_back:
                print(f"  py len {len(py_s)} js len {len(js_s)}")

    total = ok + bad
    print(f"harness: {ok}/{total} decode-equivalent "
          f"({len(synthetic_vectors())} synthetic + {total - len(synthetic_vectors())} real packs)"
          + ("" if bad == 0 else f"  <-- {bad} FAILURES"))
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
