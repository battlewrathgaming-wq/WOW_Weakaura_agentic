"""
fuse_check.py - drift detector for this project's recurring FUSE mount-lag
bug (see CLAUDE.md/DEV_TOOLS.md). NOT an automatic fixer - the sandbox's
bash-mounted view of a file has repeatedly been observed serving stale or
truncated bytes for files edited multiple times in one session (via the
Read/Edit/Write tools), even though those tools' own view is correct and
current. This script can't independently know which view is "right" - it
has no access to the Read tool's side. What it DOES do is give a fast,
cheap snapshot (line count/size/hash/mtime) of what bash currently sees,
so drift gets caught in one quick call right after an edit, instead of
discovered mid-task via a confusing traceback (an "unterminated string
literal" deep inside a 1300-line file, say - the exact way this bug has
bitten real work more than once).

Usage:
    python3 fuse_check.py <file1> [file2 ...]
    python3 fuse_check.py --scan          # every .py/.json file in this folder tree
    python3 fuse_check.py --scan --save   # also write a snapshot to .fuse_manifest.json
    python3 fuse_check.py --scan --diff   # compare against the last saved snapshot, list only what changed

Recommended use: right after Edit/Write-ing a file that's already been
touched multiple times this session (build_templates.py has been the
repeat offender), run this once on that file. If the reported line count
doesn't match what you expect from the edit you just made, that's the
signal bash's view is stale - bypass it by rewriting the file directly
via a bash heredoc (`cat > path << 'EOF' ... EOF`) using the content you
already have from the Read tool. That heredoc-write has been the one
reliable fix this project has found so far; this script exists to tell
you WHEN that's needed, not to perform the fix itself.
"""
import argparse
import hashlib
import json
import os
import sys

_THIS_DIR = os.path.dirname(os.path.abspath(__file__))
MANIFEST_PATH = os.path.join(_THIS_DIR, ".fuse_manifest.json")

SCAN_EXTENSIONS = (".py", ".json")
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
    parser.add_argument("--scan", action="store_true", help="Check every .py/.json file under this folder tree.")
    parser.add_argument("--save", action="store_true", help="Save this run's snapshot as the new baseline.")
    parser.add_argument("--diff", action="store_true", help="Compare against the saved baseline, print only changes.")
    args = parser.parse_args()

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
