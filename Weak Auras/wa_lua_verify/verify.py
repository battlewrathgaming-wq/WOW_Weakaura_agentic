"""
verify.py - diffs this project's own template subRegions against the REAL
WeakAuras source's default() tables (extracted via harness.lua run under a
real Lua 5.1 interpreter), catching missing-field gaps like the one that
shipped in class_accent_tick_end/threshold_value before a live test had to
catch it. See README.md in this folder for the full rationale.

Reports per FILE + subRegion instance, not just per subRegion type -
a type being correct in one template doesn't mean it's correct
everywhere else that type is used (this is exactly how it caught
resource_threshold_aurabar/swing_timer_aurabar's subtext still missing
3 fields that player_cast_aurabar's subtext had already been fixed to
include).

Usage: python3 verify.py <Templates/templates dir> <SubRegionTypes dir> <lua5.1 binary> <harness.lua>
"""
import json
import os
import subprocess
import sys
import time


def read_json_robust(path, retries=5, delay=0.3):
    """This project's sandbox has a known FUSE-mount-lag quirk where a
    file read immediately after an edit can come back stale or
    truncated (sometimes with trailing null bytes, sometimes just cut
    short). Retry a few times before giving up - a real parse error on
    a stable file still surfaces once retries are exhausted."""
    last_err = None
    for _ in range(retries):
        with open(path, "rb") as f:
            data = f.read()
        clean = data.split(b"\x00")[0]
        try:
            return json.loads(clean.decode("utf-8"))
        except json.JSONDecodeError as e:
            last_err = e
            time.sleep(delay)
    raise last_err


def collect_real_defaults(subregiontypes_dir, lua_bin, harness_path):
    """subRegion type -> set of field names in WeakAuras' own real
    default() table, extracted by actually executing the real,
    unmodified source file under Lua 5.1 (not hand-transcribed)."""
    real = {}
    for fname in sorted(os.listdir(subregiontypes_dir)):
        if not fname.endswith(".lua"):
            continue
        path = os.path.join(subregiontypes_dir, fname)
        proc = subprocess.run([lua_bin, harness_path, path], capture_output=True, text=True)
        if proc.returncode != 0:
            print(f"  [warn] {fname}: harness failed - {proc.stderr.strip()}")
            continue
        try:
            parsed = json.loads(proc.stdout)
        except json.JSONDecodeError:
            print(f"  [warn] {fname}: harness produced non-JSON output")
            continue
        by_base = {}
        for key, table in parsed.items():
            if ":" in key:
                base, variant = key.split(":", 1)
            else:
                base, variant = key, None
            by_base.setdefault(base, {})[variant] = table
        for base, variants in by_base.items():
            # Prefer the "aurabar" variant since every subRegion this
            # project uses lives on an aurabar region.
            chosen = None
            for k in ("aurabar", None, "icon", "none"):
                if k in variants:
                    chosen = variants[k]
                    break
            if chosen is not None:
                real[base] = set(chosen.keys())
    return real


def main():
    if len(sys.argv) < 5:
        print(__doc__)
        sys.exit(1)
    templates_dir, subregiontypes_dir, lua_bin, harness_path = sys.argv[1:5]

    print("Extracting real default() tables via Lua 5.1 harness...")
    real = collect_real_defaults(subregiontypes_dir, lua_bin, harness_path)
    print(f"  found real defaults for: {sorted(real)}\n")

    print("Checking every subRegion instance in every template...")
    print("=" * 70)
    any_gap = False
    for fname in sorted(os.listdir(templates_dir)):
        if not fname.endswith(".template.json"):
            continue
        path = os.path.join(templates_dir, fname)
        try:
            data = read_json_robust(path)
        except Exception as e:
            print(f"[SKIP] {fname}: could not parse ({e})")
            continue
        for i, sub in enumerate(data.get("subRegions", [])):
            t = sub.get("type")
            if not t:
                continue
            if t not in real:
                print(f"[?]       {fname} subRegions[{i}] ({t}): no real default() found")
                continue
            missing = real[t] - set(sub.keys())
            if missing:
                any_gap = True
                print(f"[MISSING] {fname} subRegions[{i}] ({t}): {sorted(missing)}")
            else:
                print(f"[OK]      {fname} subRegions[{i}] ({t})")
    print("=" * 70)
    if any_gap:
        print("Result: real gaps found vs WeakAuras' own default() tables - see [MISSING] above.")
        sys.exit(1)
    else:
        print("Result: every subRegion instance matches or exceeds its real default() field set.")


if __name__ == "__main__":
    main()
