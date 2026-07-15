"""
pull.py - the landing zone: client SavedVariables -> provenance-stamped repo records.

The other half of COA_DevDump v2's mailbox: the addon writes ONE envelope per
run ({header, payload}) into COA_DevDumpDB; /reload flushes it to the WTF
file; this tool lands it in the repo. Landing = clone the flushed file
VERBATIM into raw/ (the local audit receipt, gitignored), then parse it with
the codec-proven `Weak Auras/lua_table.py` into records/<runId>__<task>.json
(tracked - the capture is not reproducible from the repo). The header's runId
dedupes: re-flushing an unchanged mailbox lands nothing.

Usage:
    py addons\\landing\\pull.py once          land the current mailbox (says why if it can't)
    py addons\\landing\\pull.py watch         leave running: poll the WTF file, land every fresh flush
    py addons\\landing\\pull.py once --file X  land an arbitrary SV file (testing)

By-exception in watch mode: one line per landing or error; an unchanged
mailbox (every ordinary /reload rewrites the file) passes silently.
"""
import hashlib
import json
import re
import shutil
import sys
import time
from datetime import datetime
from pathlib import Path

LANDING = Path(__file__).resolve().parent
REPO = LANDING.parent.parent
sys.path.insert(0, str(REPO / "Weak Auras"))
from lua_table import parse_file, LuaParseError  # noqa: E402  (codec-proven parser, reused not re-derived)

SV_FILE = Path(r"F:\games\Ascension_wow\resources\ascension-live\WTF\Account"
               r"\BATTLEWRATH\SavedVariables\COA_DevDump.lua")
RAW = LANDING / "raw"          # verbatim clones (local receipts, gitignored)
RECORDS = LANDING / "records"  # parsed records (tracked)

POLL_SECONDS = 2


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 16), b""):
            h.update(chunk)
    return h.hexdigest()


def land(sv_path: Path):
    """Try to land the mailbox. Returns (status, detail) - status one of
    landed / already / empty / parse-error / missing."""
    if not sv_path.is_file():
        return "missing", f"no SavedVariables file at {sv_path}"
    try:
        db = parse_file(str(sv_path)).get("COA_DevDumpDB")
    except LuaParseError as e:
        return "parse-error", str(e)
    if not isinstance(db, dict) or not isinstance(db.get("header"), dict):
        return "empty", "no v2 envelope in the mailbox (empty, cleared, or pre-v2 data)"

    header = db["header"]
    run_id = header.get("runId")
    task = re.sub(r"[^A-Za-z0-9_-]", "_", str(header.get("task", "unknown")))
    if not run_id:
        return "parse-error", "envelope has no runId - header malformed"

    name = f"{run_id}__{task}"
    record_path = RECORDS / f"{name}.json"
    if record_path.exists():
        return "already", name

    RAW.mkdir(exist_ok=True)
    RECORDS.mkdir(exist_ok=True)
    raw_path = RAW / f"{name}.lua"
    shutil.copy2(sv_path, raw_path)

    record = {
        "_provenance": {
            "source": str(sv_path),
            "source_mtime": datetime.fromtimestamp(sv_path.stat().st_mtime).isoformat(timespec="seconds"),
            "pulled_at": datetime.now().isoformat(timespec="seconds"),
            "sha256": sha256(raw_path),
            "raw_clone": str(raw_path.relative_to(REPO)),
            "envelope_status": header.get("status"),
        },
        "header": header,
        "payload": db.get("payload"),
    }
    with open(record_path, "w", encoding="utf-8") as f:
        json.dump(record, f, indent=2, ensure_ascii=False)

    note = "" if header.get("status") == "complete" else \
        f" [WARNING: envelope status='{header.get('status')}' - flushed mid-session?]"
    return "landed", f"{record_path.relative_to(REPO)}{note}"


def watch(sv_path: Path):
    print(f"Watching {sv_path}")
    print(f"Landing into {RECORDS.relative_to(REPO)} (raw receipts in {RAW.relative_to(REPO)}). Ctrl-C to stop.")
    last_sig = None
    while True:
        try:
            st = sv_path.stat()
            sig = (st.st_mtime_ns, st.st_size)
        except OSError:
            sig = None
        if sig is not None and sig != last_sig:
            if last_sig is not None:      # a fresh flush, not startup
                time.sleep(1.0)           # let the client finish writing
            status, detail = land(sv_path)
            stamp = datetime.now().strftime("%H:%M:%S")
            if status == "landed":
                print(f"[{stamp}] LANDED {detail}")
            elif status in ("parse-error", "missing"):
                print(f"[{stamp}] {status.upper()}: {detail}")
            elif status == "empty" and last_sig is not None:
                print(f"[{stamp}] flush seen, {detail}")
            # "already" = ordinary /reload with an unchanged mailbox: silent
            last_sig = sig if sig is not None else last_sig
        time.sleep(POLL_SECONDS)


def main():
    args = sys.argv[1:]
    sv_path = SV_FILE
    if "--file" in args:
        i = args.index("--file")
        sv_path = Path(args[i + 1])
        del args[i:i + 2]
    mode = args[0] if args else "once"

    if mode == "watch":
        try:
            watch(sv_path)
        except KeyboardInterrupt:
            print("\nWatcher stopped.")
    elif mode == "once":
        status, detail = land(sv_path)
        print(f"{status}: {detail}")
        sys.exit(0 if status in ("landed", "already") else 1)
    else:
        print(__doc__)
        sys.exit(2)


if __name__ == "__main__":
    main()
