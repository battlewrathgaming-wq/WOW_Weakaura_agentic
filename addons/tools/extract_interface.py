"""
extract_interface.py - extract a client MPQ's Interface/ code files to a local
working copy for source-grep (the census's declared-surface prong).

The client's own UI code (Ascension_* addons, FrameXML, SharedXML, LibraryXML)
ships inside Data/patch-B.MPQ - confirmed 2026-07-15 by the archive sweep:
patch-B carries ALL client-side code (823 lua / 1299 files); A/I/X are art;
the big archives hold no Interface content. mpyq handles it (the Spell.dbc
precedent; only 8 tiny listfile-less art archives are unlistable).

Output goes to Outputs/client_interface/<archive-stem>/ (GITIGNORED - this is
Ascension's client code, a study copy like the installed WA source, not our
content to track) plus a manifest.json (sha256 of the source archive, file
count, extraction time) so any census map derived from it can cite its anchor.

Usage:
    py addons\\tools\\extract_interface.py                 (patch-B.MPQ, code files)
    py addons\\tools\\extract_interface.py patch-X.MPQ     (another archive)
    py addons\\tools\\extract_interface.py patch-B.MPQ --all-types
"""
import hashlib
import json
import sys
from datetime import datetime
from pathlib import Path

import mpyq

DATA = Path(r"F:\games\Ascension_wow\resources\ascension-live\Data")
OUT_ROOT = Path(__file__).resolve().parents[2] / "Outputs" / "client_interface"

CODE_SUFFIXES = (b".lua", b".xml", b".toc")


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    all_types = "--all-types" in sys.argv
    archive_name = args[0] if args else "patch-B.MPQ"
    archive = DATA / archive_name
    if not archive.is_file():
        print(f"No archive at {archive}")
        sys.exit(2)

    out_dir = OUT_ROOT / archive.stem
    a = mpyq.MPQArchive(str(archive))
    files = a.files or []
    wanted = [f for f in files
              if f.lower().startswith(b"interface")
              and (all_types or f.lower().endswith(CODE_SUFFIXES))]

    written, failed = 0, []
    for name in wanted:
        try:
            data = a.read_file(name)
            if data is None:
                failed.append(name.decode("latin-1"))
                continue
            rel = Path(name.decode("latin-1").replace("\\", "/"))
            target = out_dir / rel
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)
            written += 1
        except Exception as e:
            failed.append(f"{name.decode('latin-1')} ({type(e).__name__})")

    manifest = {
        "source": str(archive),
        "source_sha256": sha256(archive),
        "source_mtime": datetime.fromtimestamp(archive.stat().st_mtime).isoformat(timespec="seconds"),
        "extracted_at": datetime.now().isoformat(timespec="seconds"),
        "filter": "Interface/* code files (.lua/.xml/.toc)" if not all_types else "Interface/* all types",
        "archive_files_total": len(files),
        "written": written,
        "failed": failed,
    }
    out_dir.mkdir(parents=True, exist_ok=True)
    with open(out_dir / "manifest.json", "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2)

    print(f"{archive.name}: {written} files -> {out_dir}")
    if failed:
        print(f"FAILED on {len(failed)}: " + ", ".join(failed[:10]))
    print("manifest.json written (source sha256 = the census's version anchor)")


if __name__ == "__main__":
    main()
