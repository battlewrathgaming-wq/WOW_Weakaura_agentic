#!/usr/bin/env python3
"""
watch_index.py - a small, dependency-free, self-contained real-time index
for THIS project folder only (scoped to "project_games" -
F:\\Projects_games\\World of Warcraft - Conquest of Azeroth - never any
other folder on the device).

WHY THIS EXISTS
---------------
Built 2026-07-07, per Battlewrath's request after discussing the FUSE
mount-lag bug and the local filesystem MCP server: search_files (the MCP
filesystem server's own tool) only matches file NAMES/paths, not file
CONTENTS - finding "which file mentions POWERTYPE_RAGE" meant grepping
files one at a time. Separately, fuse_check.py's existing --scan/--save/
--diff workflow is snapshot-based (only knows what changed since the last
time someone ran it), not real-time.

This script is a small evolution of both ideas in one place: a metadata
index (path/size/mtime/hash/line_count - same fields fuse_check.py's
manifest already tracks, so it can be used as a drop-in staleness check
too) PLUS a simple inverted word index for fast full-text search, kept
current by a polling loop rather than a one-shot scan.

SCOPE / SAFETY RULES (explicit, per Battlewrath's request):
- Only ever walks the project root this script lives under (resolved
  relative to this file's own path - see PROJECT_ROOT below). It never
  reads any other folder on the device (not Ascension_wow, not
  ProjectAscension, not anywhere in C:\\). No absolute path outside
  PROJECT_ROOT is ever touched.
- Zero third-party dependencies - pure standard library (os, sys, json,
  time, hashlib, re, argparse). Nothing gets pip-installed anywhere, so
  there is no C-drive site-packages footprint at all. Contrast with a
  watchdog/chokidar-based watcher, which would need a package install.
- All output (index.json, search_index.json, activity.log) is written
  INSIDE this same project_index/ folder, in plain, directly-readable
  JSON/text - not to any OS temp dir, not to C:\\Users\\...\\AppData, not
  anywhere outside the project.
- Does NOT log file CONTENTS anywhere, and does not log any activity
  outside this one project folder - activity.log only ever records
  <timestamp> <added/changed/removed> <relative path> lines for files
  already inside PROJECT_ROOT.

WHAT IT DOES NOT DO
--------------------
Does not execute anything, does not modify any project file, does not
watch or touch any other folder. It only reads metadata + text content of
files already inside this project and writes its own index/log files.

USAGE
-----
    python3 watch_index.py                  # continuous watch loop (default 3s poll)
    python3 watch_index.py --once           # single pass, write index, exit
    python3 watch_index.py --interval 5     # custom poll interval (seconds)
    python3 watch_index.py --search "term"  # query the existing search_index.json, no scan
"""
import argparse
import hashlib
import json
import os
import re
import sys
import time

_THIS_DIR = os.path.dirname(os.path.abspath(__file__))
# project_index/ lives at Weak Auras/Tools/project_index/ - three levels
# under the actual project root (F:\Projects_games\World of Warcraft -
# Conquest of Azeroth). Resolved relative to this file, never hardcoded,
# so the whole tool stays portable and provably scoped to wherever it
# actually sits on disk.
PROJECT_ROOT = os.path.abspath(os.path.join(_THIS_DIR, "..", "..", ".."))
OUTPUT_DIR = _THIS_DIR
INDEX_PATH = os.path.join(OUTPUT_DIR, "index.json")
SEARCH_INDEX_PATH = os.path.join(OUTPUT_DIR, "search_index.json")
LOG_PATH = os.path.join(OUTPUT_DIR, "activity.log")

# Directories never walked into at all - build artifacts / VCS internals /
# dependency trees, never genuine project content.
EXCLUDE_DIRS = {".git", "node_modules", "__pycache__", ".vs", ".vscode", ".idea"}

# File-name patterns never indexed at all (still skipped even if not in an
# excluded dir).
EXCLUDE_FILE_SUFFIXES = (".pyc", ".pyo", ".log")
EXCLUDE_FILE_NAMES = {"index.json", "search_index.json", "activity.log", ".fuse_manifest.json"}

# Extensions whose CONTENT gets read + word-indexed. Everything else still
# gets metadata-tracked (size/mtime/hash) but not content-searched - keeps
# this from ever trying to decode a binary file (images, .txt exports of
# game data that might be huge, etc.) as UTF-8 text.
TEXT_EXTENSIONS = {
    ".py", ".md", ".json", ".txt", ".lua", ".js", ".jsx", ".ts",
    ".html", ".css", ".bat", ".cfg", ".yml", ".yaml", ".toml", ".ini",
}

# BLOAT CONTROL: files larger than this still get metadata-tracked (size/
# mtime/hash/line_count) but are NOT word-indexed - large generated dumps
# (decoded WeakAura exports, full-class HTML sheets, talent JSON exports)
# were inflating search_index.json with thousands of one-off tokens for
# content nobody actually full-text-searches. 300KB comfortably covers every
# hand-written source/doc file in this project and only excludes the big
# generated artifacts.
MAX_INDEXABLE_BYTES = 300_000

# BLOAT CONTROL: activity.log is append-only. A continuous watch loop that
# logged a heartbeat line every poll cycle (even with zero changes) would
# grow unbounded over a long-running session. Heartbeats are only logged for
# --once (useful single-run feedback); the watch loop only ever logs real
# added/changed/removed events. As a second safety net, the log is trimmed
# to its last MAX_LOG_LINES whenever it grows past that.
MAX_LOG_LINES = 5000
TRIMMED_LOG_LINES = 2000

_TOKEN_RE = re.compile(r"[A-Za-z0-9_]{2,}")


def _should_skip_dir(dirname):
    return dirname in EXCLUDE_DIRS


def _should_skip_file(filename):
    if filename in EXCLUDE_FILE_NAMES:
        return True
    return any(filename.endswith(suf) for suf in EXCLUDE_FILE_SUFFIXES)


def _hash_file(path):
    h = hashlib.sha256()
    try:
        with open(path, "rb") as f:
            for chunk in iter(lambda: f.read(65536), b""):
                h.update(chunk)
        return h.hexdigest()[:16]  # short hash - collision risk is fine for a drift-check, not a security use
    except Exception:
        return None


def _read_text_safely(path):
    try:
        with open(path, "r", encoding="utf-8", errors="replace") as f:
            return f.read()
    except Exception:
        return None


def _walk_project():
    """Yields (abs_path, rel_path) for every file under PROJECT_ROOT that
    isn't excluded. Never yields anything outside PROJECT_ROOT."""
    for dirpath, dirnames, filenames in os.walk(PROJECT_ROOT):
        dirnames[:] = [d for d in dirnames if not _should_skip_dir(d)]
        for filename in filenames:
            if _should_skip_file(filename):
                continue
            abs_path = os.path.join(dirpath, filename)
            rel_path = os.path.relpath(abs_path, PROJECT_ROOT)
            yield abs_path, rel_path


def build_index(previous_index=None):
    """One full pass over the project tree. Reuses previous_index's hash
    for any file whose size+mtime haven't changed, so a poll cycle only
    pays the hashing/read cost for files that actually changed - keeps
    real-time polling cheap even over hundreds of files."""
    previous_index = previous_index or {}
    new_index = {}
    word_index = {}
    changes = []  # (kind, rel_path) - "added" | "changed" | "removed"

    seen_rel_paths = set()

    for abs_path, rel_path in _walk_project():
        seen_rel_paths.add(rel_path)
        try:
            st = os.stat(abs_path)
        except OSError:
            continue
        size, mtime = st.st_size, st.st_mtime

        prev = previous_index.get(rel_path)
        unchanged = prev is not None and prev["size"] == size and prev["mtime"] == mtime
        ext = os.path.splitext(rel_path)[1].lower()

        # Text content is read at most ONCE per file per pass, regardless
        # of whether metadata changed - it's needed both for line_count
        # (only on a real change, to avoid re-hashing unnecessarily) and
        # for the word index (rebuilt every pass so search stays accurate
        # even for files whose bytes are unchanged since last poll).
        # Oversized files are skipped for word-indexing (bloat control -
        # see MAX_INDEXABLE_BYTES) but still get metadata-tracked normally.
        indexable = ext in TEXT_EXTENSIONS and size <= MAX_INDEXABLE_BYTES
        text = _read_text_safely(abs_path) if indexable else None

        if unchanged:
            entry = dict(prev)
        else:
            file_hash = _hash_file(abs_path)
            entry = {"size": size, "mtime": mtime, "hash": file_hash, "line_count": None}
            if text is not None:
                entry["line_count"] = text.count("\n") + 1
            if prev is None:
                changes.append(("added", rel_path))
            elif prev.get("hash") != entry.get("hash"):
                changes.append(("changed", rel_path))

        new_index[rel_path] = entry

        if text:
            for token in set(_TOKEN_RE.findall(text)):
                word_index.setdefault(token.lower(), []).append(rel_path)

    for rel_path in list(previous_index):
        if rel_path not in seen_rel_paths:
            changes.append(("removed", rel_path))

    for token in word_index:
        word_index[token] = sorted(set(word_index[token]))

    return new_index, word_index, changes


def _compact_search_index(word_index):
    """Converts {token: [rel_path, ...]} into a compact, deduplicated form:
    {"files": [rel_path, ...], "index": {token: [file_id, ...]}}. BLOAT
    CONTROL: every posting normally repeats the full relative path string
    (often 40+ chars); storing a single shared file list and referencing it
    by small integer id instead cut this project's search_index.json from
    ~8.2MB to well under 1MB with no loss of information."""
    files = sorted({p for paths in word_index.values() for p in paths})
    file_id = {p: i for i, p in enumerate(files)}
    index = {
        token: sorted(file_id[p] for p in paths)
        for token, paths in word_index.items()
    }
    return {"files": files, "index": index}


def _expand_search_index(compact):
    """Inverse of _compact_search_index - returns {token: [rel_path, ...]}
    so callers (run_search) don't need to know about the on-disk id format."""
    files = compact.get("files", [])
    return {
        token: [files[i] for i in ids if 0 <= i < len(files)]
        for token, ids in compact.get("index", {}).items()
    }


def _load_json(path):
    if os.path.exists(path):
        try:
            with open(path) as f:
                return json.load(f)
        except Exception:
            return None
    return None


def _write_json(path, data):
    with open(path, "w") as f:
        json.dump(data, f, indent=2, sort_keys=True)
        f.write("\n")


def _log(line):
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
    full_line = f"{timestamp} {line}"
    print(full_line)
    with open(LOG_PATH, "a") as f:
        f.write(full_line + "\n")
    _trim_log_if_needed()


def _trim_log_if_needed():
    """BLOAT CONTROL safety net: even with heartbeat-suppression in the
    watch loop, a long enough run (or a very active editing session) could
    still grow activity.log indefinitely. Once it passes MAX_LOG_LINES,
    keep only the most recent TRIMMED_LOG_LINES - this is a plain local
    file trim, nothing is sent anywhere."""
    if not os.path.exists(LOG_PATH):
        return
    with open(LOG_PATH) as f:
        lines = f.readlines()
    if len(lines) > MAX_LOG_LINES:
        kept = lines[-TRIMMED_LOG_LINES:]
        with open(LOG_PATH, "w") as f:
            f.write(f"... trimmed, keeping last {len(kept)} lines ...\n")
            f.writelines(kept)


def run_once(log_heartbeat=True):
    previous_index = _load_json(INDEX_PATH) or {}
    new_index, word_index, changes = build_index(previous_index)
    _write_json(INDEX_PATH, new_index)
    _write_json(SEARCH_INDEX_PATH, _compact_search_index(word_index))
    if changes:
        for kind, rel_path in changes:
            _log(f"{kind} {rel_path}")
    elif log_heartbeat:
        _log(f"scan complete, no changes ({len(new_index)} files tracked)")
    return new_index, word_index, changes


def run_watch(interval):
    _log(f"watch_index.py starting - scoped to {PROJECT_ROOT}, poll every {interval}s")
    try:
        while True:
            # log_heartbeat=False - BLOAT CONTROL: a continuous loop only
            # logs real added/changed/removed events, never a repeating
            # "no changes" line every poll cycle.
            run_once(log_heartbeat=False)
            time.sleep(interval)
    except KeyboardInterrupt:
        _log("watch_index.py stopped (KeyboardInterrupt)")


def run_search(term):
    compact = _load_json(SEARCH_INDEX_PATH)
    if compact is None:
        print("No search_index.json yet - run with --once or start the watch loop first.")
        return
    word_index = _expand_search_index(compact)
    token = term.lower()
    matches = word_index.get(token)
    if not matches:
        # fall back to substring match across tokens, for partial terms
        matches = sorted({p for t, paths in word_index.items() if token in t for p in paths})
    if matches:
        print(f"'{term}' found in {len(matches)} file(s):")
        for rel_path in matches:
            print(f"  {rel_path}")
    else:
        print(f"'{term}' not found in the current index.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__.split("USAGE")[0])
    parser.add_argument("--once", action="store_true", help="Single pass, write index, exit.")
    parser.add_argument("--interval", type=float, default=3.0, help="Poll interval in seconds for watch mode (default 3).")
    parser.add_argument("--search", type=str, default=None, help="Query the existing search_index.json and exit - no scan performed.")
    args = parser.parse_args()

    if args.search is not None:
        run_search(args.search)
    elif args.once:
        run_once()
    else:
        run_watch(args.interval)
