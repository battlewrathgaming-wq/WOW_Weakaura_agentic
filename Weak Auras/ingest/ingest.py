"""
ingest.py - external WeakAura pack ingestion into the SEPARATE training pool.

Drop WA import strings (one per file, *.txt) into ingest/inbox/. Each is decoded
via weakaura_codec (lossless, version-agnostic) into ingest/reference/<name>.json
with a provenance header, and the source file is moved to ingest/processed/ (the
"tag by rename"). This pool is DISTINCT from Outputs/aura_corpus/ (the clean v86
authoritative corpus of Battlewrath's own in-game exports) - it is grammar /
training breadth: evidence of how WAs *can* be composed, from published packs.

SANITATION model:
  - Each record is stamped {internalVersion, modernized:false} - nothing here
    pretends to be current-version clean. Trust STRUCTURE (grammar), not fields,
    until Modernized.
  - Old-format (version 0/1) strings can't be decoded by this codec (it raises);
    they are reported, not ingested.
  - Modernize v?->v86 is a separate, later pass (needs the harness hardened). The
    pool is usable for structural/grammar analysis as-is - those findings are
    version-robust (see blueprint/COMPOSITION_GRAMMAR.md).

    py ingest.py            # process everything in inbox/
"""
import datetime
import json
import os
import sys

_THIS = os.path.dirname(os.path.abspath(__file__))
_WA = os.path.dirname(_THIS)
sys.path.insert(0, _WA)
import weakaura_codec as wc

INBOX = os.path.join(_THIS, "inbox")
PROCESSED = os.path.join(_THIS, "processed")
REFERENCE = os.path.join(_THIS, "reference")


def _origin_of(fname):
    """`Retail_*.txt` -> retail (modern WoW, expert grammar but non-reproducible
    content); everything else -> ascension (our WotLK 3.3.5a / WA 5.21.2 server)."""
    return "retail" if fname.lower().startswith("retail_") else "ascension"


def ingest_string(s, source):
    """Decode one import string into a provenance-stamped reference record."""
    env = wc.decode_import_string_raw(s)
    if not (isinstance(env, dict) and "d" in env):
        raise ValueError('not a WeakAuras export envelope (no top-level "d")')
    root = env["d"]
    children = env.get("c", []) or []
    ivs = [n.get("internalVersion") for n in [root] + children
           if isinstance(n, dict) and n.get("internalVersion") is not None]
    return {
        "provenance": {
            "source": source,
            "origin": _origin_of(source),   # retail | ascension
            "wa_version": env.get("s"),           # WeakAuras version string, e.g. "4.2.5"
            "format_version": env.get("v"),       # export format version (2)
            "internalVersion": root.get("internalVersion") if isinstance(root, dict) else None,
            "internalVersion_range": [min(ivs), max(ivs)] if ivs else None,
            "modernized": False,                  # NOT migrated to v86 - trust structure, not fields
            "node_count": 1 + len(children),
            "decoded_at": datetime.datetime.now().isoformat(timespec="seconds"),
        },
        "root": root,
        "children": children,
    }


def main():
    for d in (INBOX, PROCESSED, REFERENCE):
        os.makedirs(d, exist_ok=True)
    files = [f for f in sorted(os.listdir(INBOX)) if f.endswith(".txt")]
    if not files:
        print(f"inbox empty - drop WA import-string .txt files into "
              f"{os.path.relpath(INBOX, _WA)}/ and re-run")
        return 0
    ok = fail = 0
    for f in files:
        path = os.path.join(INBOX, f)
        stem = os.path.splitext(f)[0]
        s = open(path, encoding="utf-8").read().strip()
        try:
            rec = ingest_string(s, f)
        except Exception as e:
            fail += 1
            print(f"  FAIL {f}: {type(e).__name__}: {e}  (left in inbox)")
            continue
        with open(os.path.join(REFERENCE, stem + ".json"), "w", encoding="utf-8") as out:
            json.dump(rec, out, indent=1, ensure_ascii=False)
            out.write("\n")
        os.replace(path, os.path.join(PROCESSED, f))   # tag: move source out of inbox
        p = rec["provenance"]
        print(f"  OK   {f} -> reference/{stem}.json  "
              f"(iv={p['internalVersion']} range={p['internalVersion_range']}, "
              f"nodes={p['node_count']}, wa={p['wa_version']})")
        ok += 1
    print(f"ingested {ok}, failed {fail}")
    return 0 if fail == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
