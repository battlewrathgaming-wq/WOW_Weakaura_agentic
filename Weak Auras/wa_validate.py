"""
wa_validate.py - validate our Layer-0 block library against WeakAuras' OWN
schema, by running the REAL WA 5.21.2 source under Lua 5.1.5 (via wa_lua_verify's
harnesses) and diffing our blocks' fields against WA's real default() field sets.

The strongest "expected vs other" check: not "does the string decode" (the codec
already proves that) but "are these the fields WA actually defines." A field in
our block that WA's default() doesn't know is suspect (typo / stale / wrong
region); a WA field we never use is a coverage gap. This is the empirical
reconcile of our corpus-derived library against WA's authoritative spec - done
by EXECUTING WA's code, not reading the wiki.

Prereqs: Lua 5.1.5 at .tools/lua51/lua5.1.exe and the WA addon source in the game
install (see wa_lua_verify/, game-client-install-path memory).

    py wa_validate.py
"""
import glob
import json
import os
import re
import sqlite3
import subprocess

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.dirname(_THIS)
LUA = os.path.join(_ROOT, ".tools", "lua51", "lua5.1.exe")
WA = ("F:/games/Ascension_wow/resources/ascension-live/Interface/AddOns/WeakAuras")
HARNESS = os.path.join(_THIS, "wa_lua_verify")
DB = os.path.join(_ROOT, "Outputs", "aura_corpus", "blocks.db")


# WA fields NOT in a region/subregion TYPE's own default() but still legitimate:
# RegionPrototype base props (every region carries them), WA-added storage/cache
# fields (set on import/store, not defaulted), and dynamically-generated
# text-format fields (WA builds text_text_format_* per text config). Filtering
# these leaves only GENUINE unknowns (typo / stale / wrong-region) to flag.
BASE_ALLOW = {"actions", "animation", "alpha", "regionType", "preferToUpdate",
              "displayIcon", "useAdjustededMax", "useAdjustededMin",
              "displayText_format_n_format", "smoothProgress", "xOffset", "yOffset",
              "id", "uid", "internalVersion", "tocversion"}


def _legit(f):
    return f in BASE_ALLOW or f.startswith("text_text_format")


def _slug(s):
    return re.sub(r"[^a-z0-9]+", "_", str(s).lower()).strip("_")


def _run(harness, srcfile):
    r = subprocess.run([LUA, harness, srcfile], cwd=HARNESS, capture_output=True, text=True)
    out = r.stdout.strip()
    return json.loads(out) if out.startswith("{") else None


def wa_schema():
    """block_id -> set(WA default field names), extracted from real WA source."""
    schema = {}
    for f in sorted(glob.glob(os.path.join(WA, "RegionTypes", "*.lua"))):
        d = _run(os.path.join(HARNESS, "harness_regiontype.lua"), f)
        for name, fields in (d or {}).items():
            if isinstance(fields, dict) and name in ("icon", "aurabar", "text", "stopmotion",
                                                     "group", "dynamicgroup", "model", "progresstexture"):
                schema.setdefault(f"region.{_slug(name)}", set()).update(fields.keys())
    for f in sorted(glob.glob(os.path.join(WA, "SubRegionTypes", "*.lua"))):
        d = _run(os.path.join(HARNESS, "harness.lua"), f)
        for name, fields in (d or {}).items():
            base = name.split(":")[0]  # 'subtext:icon' -> 'subtext'
            if isinstance(fields, dict):
                schema.setdefault(f"subregion.{_slug(base)}", set()).update(fields.keys())
    return schema


def our_blocks():
    """block_id -> (kind, set(all fields = invariant keys | holes)) for region/subregion."""
    con = sqlite3.connect(DB)
    out = {}
    for bid, kind, ct, holes in con.execute(
            "SELECT block_id,kind,code_template,holes FROM block WHERE kind IN ('region','subregion')"):
        out[bid] = (kind, set(json.loads(ct)) | set(json.loads(holes)))
    con.close()
    return out


def main():
    if not os.path.exists(LUA):
        raise SystemExit(f"Lua 5.1 not found at {LUA}")
    schema = wa_schema()
    blocks = our_blocks()
    print(f"WA 5.21.2 schema: {len(schema)} region/subregion types extracted under Lua 5.1.5")
    print(f"our library: {len(blocks)} region/subregion blocks\n")

    unknown_total = 0
    for bid in sorted(blocks):
        kind, ours = blocks[bid]
        wa = schema.get(bid)
        if wa is None:
            print(f"  {bid:26s} NO WA SCHEMA (type not found in source?)")
            continue
        unknown = {f for f in (ours - wa) if not _legit(f)}   # genuine unknowns only
        unused = wa - ours             # WA fields we never used       -> coverage
        unknown_total += len(unknown)
        flag = f"WARN unknown={sorted(unknown)}" if unknown else "ok"
        print(f"  {bid:26s} ours:{len(ours):<3} wa:{len(wa):<3} covered:{len(ours & wa):<3} "
              f"{flag}   (WA-only options: {len(unused)})")

    print(f"\n== summary ==")
    print(f"  {unknown_total} field(s) in our blocks that WA's default() does NOT define"
          f"{' - all clean' if unknown_total == 0 else ' - inspect these (typo/stale/wrong-region)'}")


if __name__ == "__main__":
    main()
