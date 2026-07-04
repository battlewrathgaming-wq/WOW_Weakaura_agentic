"""
fuse_check.py - drift detector AND lightweight resync helper for this
project's recurring FUSE mount-lag bug (see CLAUDE.md/DEV_TOOLS.md). The
detector half still can't independently know which view is "right" - it
has no access to the Read tool's side, only bash's. What it DOES do is
give a fast, cheap snapshot (line count/size/hash/mtime) of what bash
currently sees, so drift gets caught in one quick call right after an
edit, instead of discovered mid-task via a confusing traceback (an
"unterminated string literal" deep inside a 1300-line file, say - the
exact way this bug has bitten real work more than once). Confirmed
2026-07-06 that this isn't limited to .py/.json - markdown docs edited
multiple times in one session showed the identical symptom, so `--scan`
now also covers `.md`.

Usage:
    python3 fuse_check.py <file1> [file2 ...]
    python3 fuse_check.py --scan          # every .py/.json/.md file in this folder tree
    python3 fuse_check.py --scan --save   # also write a snapshot to .fuse_manifest.json
    python3 fuse_check.py --scan --diff   # compare against the last saved snapshot, list only what changed
    python3 fuse_check.py --resync <fresh_source> <stale_target>

Recovery, cheapest option first (confirmed 2026-07-06 via a real repro:
a 3-times-edited tiny test file went stale in bash's view after the 3rd
edit; a brand-new file written once via the Write tool was NOT stale,
and `cp`-ing that fresh file over the stale target fixed it instantly):

1. **Preferred: `--resync`.** Use the Write tool to save the Read-tool-
   confirmed-correct content to a brand-new path (anything not touched
   before this session - a `*_fresh` sibling file is enough), then run
   `python3 fuse_check.py --resync <that_new_path> <the_stale_path>`.
   This copies the fresh bytes over the stale file and verifies the
   hashes now match in one step. Much less error-prone than hand-typing
   a full heredoc for a large file (no shell-escaping to get right, and
   the content only has to be correct once, in the Write call).
2. **Fallback: a bash heredoc** (`cat > path << 'EOF' ... EOF`) using the
   content from the Read tool, if for some reason a fresh temp file
   isn't practical. This was the only known fix before the `--resync`
   pattern above was confirmed, and still works.
"""
import argparse
import hashlib
import json
import os
import shutil
import sys

_THIS_DIR = os.path.dirname(os.path.abspath(__file__))
MANIFEST_PATH = os.path.join(_THIS_DIR, ".fuse_manifest.json")

SCAN_EXTENSIONS = (".py", ".json", ".md")
SCAN_SKIP_DIRS = {"__pycache__", ".git"}


def snapshot(path):
    with open(path, "rb") as f:
        data = f.read()
    return {
        "size": len(data),
        "lines": data.count(b"\n") + (1 if data and not data.endswith(b"\n") else 0),
        "sha256_16": hashlib.sha256(data).hexdigest()[:16],
        "mtime": os.path.getmtime(path),
    }


def find_scan_targets(root):
    targets = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SCAN_SKIP_DIRS]
        for name in filenames:
            if name.endswith(SCAN_EXTENSIONS):
                targets.append(os.path.relpath(os.path.join(dirpath, name), root))
    return sorted(targets)


def main():
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument("files", nargs="*", help="Specific file(s) to check.")
    parser.add_argument("--scan", action="store_true", help="Check every .py/.json/.md file under this folder tree.")
    parser.add_argument("--save", action="store_true", help="Save this run's snapshot as the new baseline.")
    parser.add_argument("--diff", action="store_true", help="Compare against the saved baseline, print only changes.")
    parser.add_argument(
        "--resync", nargs=2, metavar=("FRESH_SOURCE", "STALE_TARGET"),
        help="Copy FRESH_SOURCE (a file just written once, never touched before "
             "this session) over STALE_TARGET, then verify the hashes match.",
    )
    args = parser.parse_args()

    if args.resync:
        src, dst = args.resync
        src, dst = os.path.abspath(src), os.path.abspath(dst)
        if not os.path.isfile(src):
            print(f"FRESH_SOURCE not found: {src}")
            sys.exit(1)
        shutil.copyfile(src, dst)
        src_snap, dst_snap = snapshot(src), snapshot(dst)
        if src_snap["sha256_16"] == dst_snap["sha256_16"]:
            print(f"RESYNCED  {dst}  ({dst_snap['lines']} lines, {dst_snap['size']} bytes, hash {dst_snap['sha256_16']} matches source)")
        else:
            print(f"MISMATCH after copy - src {src_snap['sha256_16']} vs dst {dst_snap['sha256_16']}, something is still wrong")
            sys.exit(1)
        return

    if args.scan:
        rel_paths = find_scan_targets(_THIS_DIR)
        abs_paths = [os.path.join(_THIS_DIR, p) for p in rel_paths]
    else:
        if not args.files:
            parser.error("give file path(s), or use --scan")
        abs_paths = [os.path.abspath(p) for p in args.files]
        rel_paths = [os.path.relpath(p, _THIS_DIR) for p in abs_paths]

    current = {}
    for rel, absp in zip(rel_paths, abs_paths):
        if not os.path.isfile(absp):
            print(f"MISSING  {rel}")
            continue
        current[rel] = snapshot(absp)

    if args.diff:
        if not os.path.exists(MANIFEST_PATH):
            print("No saved baseline yet - run with --save first.")
            sys.exit(1)
        with open(MANIFEST_PATH) as f:
            baseline = json.load(f)
        changed = False
        for rel, snap in current.items():
            old = baseline.get(rel)
            if old is None:
                print(f"NEW      {rel}  ({snap['lines']} lines, {snap['size']} bytes)")
                changed = True
            elif old["sha256_16"] != snap["sha256_16"]:
                print(
                    f"CHANGED  {rel}  {old['lines']} -> {snap['lines']} lines, "
                    f"{old['size']} -> {snap['size']} bytes"
                )
                changed = True
        if not changed:
            print("No changes since last saved baseline.")
    else:
        for rel, snap in current.items():
            print(f"{rel:60s} {snap['lines']:6d} lines  {snap['size']:8d} bytes  {snap['sha256_16']}")

    if args.save:
        with open(MANIFEST_PATH, "w") as f:
            json.dump(current, f, indent=2)
        print(f"Saved baseline ({len(current)} files) to {MANIFEST_PATH}")


if __name__ == "__main__":
    main()
