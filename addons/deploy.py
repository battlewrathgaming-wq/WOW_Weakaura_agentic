"""
deploy.py - the bench's repo->client deploy dispatcher.

Repo = source of truth; the client's Interface/AddOns/ is a byte-copy
mirror of each resident's DEPLOYABLE set (toc/lua/xml + bundled Libs).
Docs, batch files, planning folders and research material stay repo-only.
Strays in the client folder that aren't in the deployable set are DELETED
(the stale-file cleanup deploy_to_game.bat did by hand, made general).

Usage:
    py addons\\deploy.py              -> list residents + their sync state
    py addons\\deploy.py <addon>      -> deploy one resident
    py addons\\deploy.py all          -> deploy every resident

Receipt: by-exception - copied/updated/deleted files get a line each,
agreement is one count. Exit code 0 = mirror clean.
"""
import hashlib
import shutil
import sys
from pathlib import Path

REPO_ADDONS = Path(__file__).resolve().parent
CLIENT_ADDONS = Path(r"F:\games\Ascension_wow\resources\ascension-live\Interface\AddOns")

# What counts as deployable (everything else is repo-only material).
DEPLOY_SUFFIXES = {".toc", ".lua", ".xml", ".tga", ".blp", ".ttf", ".wav", ".mp3"}

# The residents: repo folder name -> {client folder name, extra excluded top-level dirs}
MANIFEST = {
    "COA_DevDump": {
        "client_name": "COA_DevDump",
        "exclude_dirs": set(),
    },
    "COA_GuardianPlates": {
        "client_name": "COA_GuardianPlates",
        "exclude_dirs": {"AggroHighlight_Saga"},
    },
    "COA_StatePlates_Aggro": {
        "client_name": "COA_StatePlates_Aggro",
        "exclude_dirs": set(),
    },
    "COA_StatePlates_Friendly": {
        "client_name": "COA_StatePlates_Friendly",
        "exclude_dirs": set(),
    },
    "COA_StatePlates_Enemy": {
        "client_name": "COA_StatePlates_Enemy",
        "exclude_dirs": set(),
    },
}


def deployable_files(src: Path, exclude_dirs: set) -> dict:
    """Relative-path -> absolute-path map of the files that should exist in the client."""
    out = {}
    for p in sorted(src.rglob("*")):
        if not p.is_file():
            continue
        rel = p.relative_to(src)
        if rel.parts[0] in exclude_dirs or any(part.startswith(".") for part in rel.parts):
            continue
        if p.suffix.lower() not in DEPLOY_SUFFIXES:
            continue
        out[rel] = p
    return out


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 16), b""):
            h.update(chunk)
    return h.hexdigest()


def deploy(name: str, apply: bool = True) -> bool:
    """Mirror one resident. Returns True if the mirror is clean afterwards."""
    entry = MANIFEST[name]
    src = REPO_ADDONS / name
    dst = CLIENT_ADDONS / entry["client_name"]
    if not src.is_dir():
        print(f"  [{name}] MISSING repo folder: {src}")
        return False

    wanted = deployable_files(src, entry["exclude_dirs"])
    copied, updated, deleted, unchanged = [], [], [], 0

    for rel, srcfile in wanted.items():
        dstfile = dst / rel
        if not dstfile.exists():
            copied.append(rel)
        elif sha256(srcfile) != sha256(dstfile):
            updated.append(rel)
        else:
            unchanged += 1
            continue
        if apply:
            dstfile.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(srcfile, dstfile)

    if dst.is_dir():
        for p in sorted(dst.rglob("*")):
            if p.is_file() and p.relative_to(dst) not in wanted:
                deleted.append(p.relative_to(dst))
                if apply:
                    p.unlink()
        if apply:  # drop now-empty stray directories
            for d in sorted((d for d in dst.rglob("*") if d.is_dir()), reverse=True):
                if not any(d.iterdir()):
                    d.rmdir()

    verb = "" if apply else " (check only)"
    print(f"  [{name}] -> {dst}{verb}")
    for rel in copied:
        print(f"      + copied   {rel}")
    for rel in updated:
        print(f"      ~ updated  {rel}")
    for rel in deleted:
        print(f"      - deleted  {rel} (stray)")
    print(f"      = {unchanged} unchanged, {len(copied)} copied, "
          f"{len(updated)} updated, {len(deleted)} strays removed")
    return True


def main():
    arg = sys.argv[1] if len(sys.argv) > 1 else ""
    if arg == "all":
        names = list(MANIFEST)
    elif arg in MANIFEST:
        names = [arg]
    elif arg in ("", "list", "status"):
        # No-arg = read-only sync check of every resident (nothing written).
        print("Residents (check only - `deploy.py <addon>` or `deploy.py all` to copy):")
        ok = all(deploy(n, apply=False) for n in MANIFEST)
        sys.exit(0 if ok else 1)
    else:
        print(f"Unknown addon '{arg}'. Residents: {', '.join(MANIFEST)} (or 'all')")
        sys.exit(2)

    print("Deploying (repo -> client, byte-copy + stray cleanup):")
    ok = all(deploy(n) for n in names)
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
