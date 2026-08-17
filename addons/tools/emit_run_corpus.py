r"""emit_run_corpus.py - the reduced run corpus, for the analysis lane. And its proof.

★★★ WHY (Battlewrath, 2026-08-17): *"Emit. Capture from the wow log too for our use.
(Proof we can keep pointing back to.) And then emit for their use."*

Two audiences, one pass:

    THEIRS   one row per sample, the fields asklist H6 asked for. JSONL, so it
             streams and a bad row costs a line rather than a file.
    OURS     the PROOF, carried IN the artifact - source path, mtime, sha256 and
             the raw clone it was reduced from.

★★ THE PROVENANCE IS THE FIRST LINE, NOT A SIDECAR. A number quoted from this file
has to be traceable back to the bytes it came from, and a sidecar is a thing that gets
separated from its data exactly when it matters. ⚠ `_provenance` already rides on the
landed record; this copies it forward rather than re-deriving it, so the chain is
    SavedVariables -> raw clone (sha256) -> landed record -> this file
and every hop is stamped.

★ WHAT "REDUCED" MEANS HERE. H6 asked for `t, gt, x, y, z, mapID, floor` plus flags.
⚠ `ghost` is OUT (§254 - it cannot fire in a dungeon; 5,295 legs say so). `combat` and
`n` stay, because the pull index is how a transit gets attributed. And `sd`/`od` ride
along WHEN THE RUN HAS THEM: a dev capture exists FOR that pair, and dropping it in the
name of "reduced" would discard the thing the run was for.

⚠ MARKERS ARE NOT LEGS AND ARE NOT MERGED. A `start`/`end`/`pin` is an event with its
own fields (`kind`, `dead`, `killedBy`); flattening them into the sample stream would
put two record shapes in one column set. They emit to their own file.

    py addons/tools/emit_run_corpus.py                 every landed run
    py addons/tools/emit_run_corpus.py test1           one, by name fragment
    py addons/tools/emit_run_corpus.py --out <dir>     somewhere else
"""

import argparse
import glob
import io
import json
import os
import sys

sys.stdout.reconfigure(encoding="utf-8")

HERE = os.path.dirname(os.path.abspath(__file__)).replace("\\", "/")
ROOT = os.path.dirname(os.path.dirname(HERE))
LANDING = ROOT + "/addons/landing"
OUT = LANDING + "/corpus"

# ★ The core H6 set. Order is fixed so a diff between two runs is readable.
CORE = ("t", "gt", "x", "y", "z", "mapID", "floor", "combat", "n")
# ★ Carried when present - the calibration pair a dev capture exists for.
EXTRA = ("sd", "od")


def sources():
    """Landed runs, staging first, DEDUPED BY FILENAME.

    A run can sit in both staging/ and records/ - the same capture promoted, or landed
    twice - and emitting it twice writes the same output path twice and inflates the
    count. First seen wins."""
    out, seen = [], set()
    for d in ("staging", "records"):
        for p in sorted(glob.glob("%s/%s/*__dungeonrun.json" % (LANDING, d))):
            n = os.path.basename(p)
            if n not in seen:
                seen.add(n)
                out.append(p)
    return out


def row_of(leg, keys):
    r = {}
    for k in keys:
        v = leg.get(k)
        if v is not None:
            r[k] = v
    return r


def reduce_run(path, outdir):
    d = json.load(io.open(path, encoding="utf-8"))
    pay = d.get("payload") or {}
    prov = dict(d.get("_provenance") or {})
    legs = pay.get("legs") or []
    marks = pay.get("markers") or []
    if not legs:
        return None

    keys = list(CORE) + [k for k in EXTRA if any(l.get(k) is not None for l in legs)]

    # ⚠ THE HEADER CARRIES WHAT THE ROWS CANNOT. A reader must be able to answer "which
    # capture is this, at what rate, against which pin" without opening the source.
    head = {
        "_kind": "run-corpus",
        "run": pay.get("name"),
        "profile": pay.get("profile"),
        "armedAt": pay.get("armedAt"),
        "closedAt": pay.get("closedAt"),
        "instance": pay.get("instance"),
        "mapFile": pay.get("mapFile"),
        "testPin": pay.get("testPin"),
        "testPinSet": pay.get("testPinSet"),
        "fields": keys,
        "rows": len(legs),
        "markers": len(marks),
        "reducedFrom": os.path.basename(path),
        # ★★ THE PROOF, copied forward rather than re-derived.
        # ⚠ THE SHA IS OF THE FLUSH, NOT OF THIS RUN. One /reload writes every run in
        # SavedVariables, so two runs from one flush carry the SAME hash - it identifies
        # the bytes we reduced from, which is what a proof needs, but it does not single
        # out a run. `reducedFrom` is what does that.
        "_provenanceCovers": "the whole SavedVariables flush, not this run alone",
        "_provenance": prov,
    }

    base = os.path.basename(path).replace("__dungeonrun.json", "")
    p1 = "%s/%s__legs.jsonl" % (outdir, base)
    with io.open(p1, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(json.dumps(head, sort_keys=True) + "\n")
        for l in legs:
            fh.write(json.dumps(row_of(l, keys), sort_keys=True) + "\n")

    p2 = None
    if marks:
        # ⚠ Markers keep their own shape. `dead` and `killedBy` are the death signal the
        # analysis lane wanted, and they were never on a leg (§254).
        mk = ("t", "gt", "x", "y", "z", "mapID", "floor", "kind", "n", "dead",
              "killedBy", "killedByUnavailable")
        p2 = "%s/%s__markers.jsonl" % (outdir, base)
        with io.open(p2, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(json.dumps(dict(head, _kind="run-markers", fields=list(mk),
                                     rows=len(marks)), sort_keys=True) + "\n")
            for m in marks:
                fh.write(json.dumps(row_of(m, mk), sort_keys=True) + "\n")

    return {"run": pay.get("name"), "rows": len(legs), "marks": len(marks),
            "keys": keys, "legs_file": p1, "marks_file": p2,
            "raw": prov.get("raw_clone"), "sha": (prov.get("sha256") or "")[:12]}


def main():
    ap = argparse.ArgumentParser(description="reduce landed runs for the analysis lane")
    ap.add_argument("match", nargs="?", help="name fragment; omit for all")
    ap.add_argument("--out", default=OUT)
    a = ap.parse_args()

    outdir = a.out.replace("\\", "/")
    if not os.path.isdir(outdir):
        os.makedirs(outdir)

    hits = [p for p in sources() if not a.match or a.match.lower() in p.lower()]
    if not hits:
        print("")
        print("   Nothing matched." if a.match else "   No landed runs found.")
        print("")
        return 1

    print("")
    done = 0
    for p in hits:
        r = reduce_run(p, outdir)
        if not r:
            # ⚠ SAID, not skipped. A run with no legs is a real thing to know about -
            # it means a capture armed and recorded nothing.
            print("   %-46s NO LEGS - armed and recorded nothing" % os.path.basename(p)[:46])
            continue
        done += 1
        print("   %-22s %5d rows  %2d markers  %s" % (
            str(r["run"])[:22], r["rows"], r["marks"], " ".join(r["keys"])))
        print("       -> %s" % os.path.relpath(r["legs_file"], ROOT).replace("\\", "/"))
        if r["marks_file"]:
            print("       -> %s" % os.path.relpath(r["marks_file"], ROOT).replace("\\", "/"))
        # ★ The proof, printed, so the chain is visible at the moment of emitting.
        print("       proof %s  sha %s" % (r["raw"] or "(none)", r["sha"] or "(none)"))
    print("")
    print("   %d run(s) reduced into %s" % (done, os.path.relpath(outdir, ROOT).replace("\\", "/")))
    print("")
    return 0


if __name__ == "__main__":
    sys.exit(main())
