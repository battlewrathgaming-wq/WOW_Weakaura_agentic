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

SV_DIR = Path(r"F:\games\Ascension_wow\resources\ascension-live\WTF\Account"
              r"\BATTLEWRATH\SavedVariables")

# ★ THE SOURCE TABLE - the one authority on WHO LANDS.
#
# Battlewrath, 2026-08-13, choosing between hardcoding a second path and this:
# "2 sounds better. More dynamic." Hardcoding makes the THIRD addon a third
# special case; a table makes it a row.
#
# deploy.py's MANIFEST stays the one authority on who EXISTS. This is the one
# authority on who LANDS. An addon joins by adding a row here.
#
# `kind` exists because the shapes genuinely differ, and flattening them would
# put a mode flag inside one function:
#   envelope    ONE {header, payload} at a time, replaced every run - dedupe by
#               header.runId. This is COA_DevDump's mailbox.
#   collection  a KEYED table that ACCUMULATES across runs. The file only grows,
#               so dedupe is PER KEY, and "already landed" is the normal answer
#               for most keys on every flush.
# `stage` is the CONTROL Battlewrath asked for: "the non-COA_DevDump needs to be
# more controlled and limited... a manifest of what's tracked. Then release when
# we get out of the testing stage."
#
#   tracked   lands into records/ (git-TRACKED) and runs in the default sweep
#   testing   lands into staging/ (GITIGNORED) and is EXCLUDED from the sweep -
#             it must be named with --source
#
# Two guards, because they stop two different things: staging/ stops repo churn
# (a collection source lands a full run per play session - run 1 alone is 50 KB),
# and exclusion from the sweep stops SURPRISE, so a watcher left running cannot
# quietly begin tracking a new addon because someone added a row.
#
# ★★★ §265: AND THEY ARE SET SEPARATELY NOW. `stage` still picks the destination;
# `sweep: True` opts a testing-stage row into the default sweep on its own. They were
# one field, so wanting "lands automatically, stays out of git" was inexpressible - the
# only way to watch a testing source was `--source`, which REPLACES the list, so you
# traded away watching devdump to get it.
#
# ⚠ The surprise-guard is intact, and it is worth being precise about what it guards:
# an UNREVIEWED row landing by default. A row carrying `sweep: True` was reviewed - the
# flag is a deliberate, greppable commit, the same lever as promotion, and a new row
# still defaults to unswept. What it does NOT do is make the source tracked.
#
# PROMOTION IS ONE WORD HERE - a deliberate, reviewable commit rather than drift.
# ★★★ AND records/ ACCUMULATES ON PURPOSE (Battlewrath, 2026-08-16). The stage is per
# SOURCE, not per record - `tracked` means EVERY capture from it is committed forever,
# and nothing prunes. 66 files / 14M at the time of writing.
#
# His call, asked and answered rather than assumed: *"We'll keep collecting. No harm.
# We have 90gb to play with. Just so we know. Purge it and promote useful when it's a
# problem."*
#
# ⚠ So a future reader finding three near-identical captures minutes apart is looking at
# a DECISION, not drift - do not helpfully prune, and do not re-raise it as a finding.
# When it does become a problem the lever is to move a source to `testing` (landing in
# gitignored staging/) and promote exemplars by hand.
SOURCES = {
    "devdump": {
        "sv": SV_DIR / "COA_DevDump.lua",
        "global": "COA_DevDumpDB",
        "kind": "envelope",
        # The mailbox: one deliberate envelope per capture. This is the shape the
        # lane was built for, so it stays tracked.
        "stage": "tracked",
    },
    "dungeonrun": {
        "sv": SV_DIR / "COA_DungeonRun.lua",
        "global": "COA_DungeonRunDB",
        "kind": "collection",
        "collection": "runs",
        "stamp": "armedAt",
        # Testing stage: the record shape is still moving, and every session would
        # otherwise commit another full run. Promote when the POC settles.
        "stage": "testing",
        # ★ §265: SWEPT ANYWAY. Dev captures (`/dr armdev`) arrive every session in the
        # heavy dev loop, and a walk that has to be remembered into the desk by hand is a
        # walk that gets lost - run 1 already was.
        #
        # ⚠ TEMPORARY BY INTENT (Battlewrath, 2026-08-17): *"We'll turn it off when out
        # of the heavy dev loop now."* So this flag is not the settled state - a reader
        # finding it later should ask whether the loop is still hot, not preserve it.
        # Removing the line is the whole revert; the row goes back to needing --source.
        "sweep": True,
    },
    # ★ ROUTES ARE A SECOND DATA FORM (dungeonrun_poc.md §61) and land separately.
    # The runs source reads `.runs`, so an authored route was invisible to the desk
    # until now - which is how "height map" could exist in game and be unreachable
    # here. Same shape, different collection.
    "dungeonroutes": {
        "sv": SV_DIR / "COA_DungeonRun.lua",
        "global": "COA_DungeonRunDB",
        "kind": "collection",
        "collection": "routes",
        "stamp": "madeAt",
        "stage": "testing",
    },
    # ⚠ NOT LANDED, deliberately: COA_DungeonRunDB.notes. §63 made personal notes
    # the one thing that never travels - they are the author's own, keyed by mapID,
    # and excluded from the export manifest by design. Pulling them to the desk
    # would be the first place that principle got quietly bent, and nothing needs
    # them. If a debugging session ever does, add it deliberately and say so.
}
RAW = LANDING / "raw"          # verbatim clones (local receipts, gitignored)
RECORDS = LANDING / "records"  # parsed records from TRACKED sources (git-tracked)
STAGING = LANDING / "staging"  # parsed records from TESTING sources (gitignored)


def dest(src: dict):
    return RECORDS if src.get("stage", "tracked") == "tracked" else STAGING


def swept(src: dict) -> bool:
    """★ §265. In the default sweep? Tracked sources always; a testing source only
    when its row says so. Separate from `dest` on purpose - WHERE it lands and WHETHER
    it lands unasked are different questions."""
    return src.get("stage", "tracked") == "tracked" or bool(src.get("sweep"))

POLL_SECONDS = 2


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 16), b""):
            h.update(chunk)
    return h.hexdigest()


def safe(text) -> str:
    return re.sub(r"[^A-Za-z0-9_-]", "_", str(text))


def _write(record_path: Path, sv_path: Path, raw_name: str, header, payload):
    """Clone the source verbatim, then write the parsed record beside it.

    The raw clone is the receipt: every record can be re-derived from the bytes
    it came from, and the sha proves nothing moved underneath.
    """
    RAW.mkdir(exist_ok=True)
    record_path.parent.mkdir(exist_ok=True)
    raw_path = RAW / f"{raw_name}.lua"
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
        "payload": payload,
    }
    with open(record_path, "w", encoding="utf-8") as f:
        json.dump(record, f, indent=2, ensure_ascii=False)


def land_collection(name: str, src: dict, db: dict):
    """An ACCUMULATING keyed table: land each key once, leave the rest alone."""
    items = db.get(src["collection"])
    if not isinstance(items, dict) or not items:
        return "empty", f"{src['global']}.{src['collection']} is empty"

    sv_path, landed, skipped = src["sv"], [], 0
    out_dir = dest(src)
    for key, entry in sorted(items.items()):
        if not isinstance(entry, dict):
            continue
        try:
            stamp = datetime.fromtimestamp(float(entry.get(src.get("stamp")))).strftime("%Y%m%d_%H%M%S")
        except (TypeError, ValueError):
            # No usable timestamp is a FACT about the entry, not a reason to drop
            # it. Name it so it still lands, and sorts first rather than vanishing.
            stamp = "00000000_000000"
        rec_name = f"{stamp}__{safe(key)}__{name}"
        record_path = out_dir / f"{rec_name}.json"
        # Already-landed is checked in BOTH destinations. Run 1 is a TRACKED
        # exemplar that predates this flag and is cited as evidence in the design
        # note (dungeonrun_poc.md section 13) - demoting the source must not
        # re-land it into staging as a duplicate.
        if record_path.exists() or (RECORDS / f"{rec_name}.json").exists():
            skipped += 1
            continue
        header = {
            "tool": src["global"],
            "kind": "collection",
            "collection": src["collection"],
            "key": key,
            "status": "complete" if entry.get("closedAt") else "open",
        }
        _write(record_path, sv_path, rec_name, header, entry)
        landed.append(str(record_path.relative_to(REPO)))

    if not landed:
        return "already", f"{skipped} entr(ies), none new"
    return "landed", " | ".join(landed) + (f"  ({skipped} already)" if skipped else "")


def land(name: str = "devdump"):
    """Land ONE source. Returns (status, detail) - status one of
    landed / already / empty / parse-error / missing."""
    src = SOURCES[name]
    sv_path = src["sv"]
    if not sv_path.is_file():
        return "missing", f"no SavedVariables file at {sv_path}"
    try:
        db = parse_file(str(sv_path)).get(src["global"])
    except LuaParseError as e:
        return "parse-error", str(e)
    if not isinstance(db, dict):
        return "empty", f"no {src['global']} in {sv_path.name}"

    if src["kind"] == "collection":
        return land_collection(name, src, db)

    if not isinstance(db.get("header"), dict):
        return "empty", "no v2 envelope in the mailbox (empty, cleared, or pre-v2 data)"

    header = db["header"]
    run_id = header.get("runId")
    task = safe(header.get("task", "unknown"))
    if not run_id:
        return "parse-error", "envelope has no runId - header malformed"

    rec_name = f"{run_id}__{task}"
    record_path = dest(src) / f"{rec_name}.json"
    if record_path.exists():
        return "already", rec_name

    _write(record_path, sv_path, rec_name, header, db.get("payload"))

    note = "" if header.get("status") == "complete" else \
        f" [WARNING: envelope status='{header.get('status')}' - flushed mid-session?]"
    return "landed", f"{record_path.relative_to(REPO)}{note}"


def watch(names):
    """Watch every named source. One /reload flushes them all, so watching one
    file and calling it "the watcher" was exactly the gap that lost run 1."""
    for n in names:
        src = SOURCES[n]
        print(f"Watching {src['sv'].name}  ({src['kind']}, {src.get('stage', 'tracked')}"
              f" -> {dest(src).name}/)")
    print(f"Landing into {RECORDS.relative_to(REPO)} (raw receipts in {RAW.relative_to(REPO)}). Ctrl-C to stop.")
    last = {n: None for n in names}
    while True:
        for n in names:
            try:
                st = SOURCES[n]["sv"].stat()
                sig = (st.st_mtime_ns, st.st_size)
            except OSError:
                sig = None
            if sig is None or sig == last[n]:
                continue
            if last[n] is not None:       # a fresh flush, not startup
                time.sleep(1.0)           # let the client finish writing
            status, detail = land(n)
            stamp = datetime.now().strftime("%H:%M:%S")
            if status == "landed":
                print(f"[{stamp}] LANDED {detail}")
            elif status in ("parse-error", "missing"):
                print(f"[{stamp}] {n} {status.upper()}: {detail}")
            elif status == "empty" and last[n] is not None:
                print(f"[{stamp}] {n} flush seen, {detail}")
            # "already" = an ordinary /reload with nothing new: silent
            last[n] = sig
        time.sleep(POLL_SECONDS)


def main():
    args = sys.argv[1:]
    # Default sweep is tracked sources, plus any testing source whose row opts in with
    # `sweep: True` (§265). A row that says neither must be named, so nothing starts
    # landing by surprise.
    names = [n for n, s_ in SOURCES.items() if swept(s_)]
    if "--source" in args:
        i = args.index("--source")
        want = args[i + 1]
        del args[i:i + 2]
        if want not in SOURCES:
            print(f"Unknown source {want!r}. Known: {', '.join(SOURCES)}")
            sys.exit(2)
        names = [want]
    mode = args[0] if args else "once"

    if mode == "watch":
        try:
            watch(names)
        except KeyboardInterrupt:
            print("\nWatcher stopped.")
    elif mode == "once":
        worst = 0
        for n in names:
            status, detail = land(n)
            print(f"{n}: {status}: {detail}")
            if status not in ("landed", "already", "empty"):
                worst = 1
        sys.exit(worst)
    elif mode == "sources":
        # ★ The two guards get two columns, because they are two facts now. One glyph
        # covering both is how they got conflated in the first place.
        for n, src in SOURCES.items():
            stage = src.get("stage", "tracked")
            where = dest(src).name
            mark = " " if stage == "tracked" else "*"
            how = "swept" if swept(src) else "--source"
            print(f"{mark}{n:14} {stage:8} -> {where:8} {how:8} {src['kind']:11}"
                  f" {src['global']}")
        print("\n* = testing stage: lands in gitignored staging/, never committed.")
        print("swept    = in the default sweep, so `watch` picks it up unasked.")
        print("--source = excluded; name it to land it.")
        print("\nThe two are independent (265): * + swept means it lands"
              " automatically and stays out of git.")
    else:
        print(__doc__)
        sys.exit(2)


if __name__ == "__main__":
    main()
