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
# ⚠ This one is an AGREEMENT (H6 asked for it), so it is not the place to bolt things on.
# Anything found later goes in CARRIED below, where it can be argued with.
CORE = ("t", "gt", "x", "y", "z", "mapID", "floor", "combat", "n")

# ★★★ §269: CARRIED WHEN PRESENT - and every entry says why it is here, because the
# alternative is a tuple nobody can audit.
#
#   sd, od   the calibration pair a dev capture exists FOR. Dropping it in the name of
#            "reduced" would discard the thing the run was for.
#   ts       ⚠⚠ THE TARGET STATE, AND ITS ABSENCE WAS A REAL GAP. `satnav_rows` has
#            carried `ts` since §263 while this reducer did not - the SAME concept in
#            two views with different columns, so a reader comparing a probe record
#            against a run record silently lost the field in one of them. It is also
#            the field the whole 2026-08-17 tracker finding rests on (0 declined /
#            2 tracking / 4 inside the flip), which made that finding uncheckable from
#            the corpus - the artifact that exists so nobody has to open the raw.
#   mapX,    the map FRACTION coordinates. ⚠ Present and VARYING on all 12 landed runs
#   mapY     and dropped silently since the emitter was written. They are C1's whole
#            subject (fraction→world is linear per map), so the one transform the desk
#            has proved could not be re-checked against the view that proved it.
CARRIED = ("sd", "od", "ts", "mapX", "mapY")

# ⚠ NAMED, NOT BLANK. These exist on every leg and are deliberately not emitted - each
# is CONSTANT across all 12 landed runs, so a column of it would be 4,952 copies of one
# value. ★ But a checked blank and an unexamined blank look identical afterwards, so the
# header carries this list: a reader can tell "we looked and it says nothing" from "the
# emitter never knew about it".
OMITTED = {
    "mapC": "constant -1 on every run - no observed meaning",
    "mapZ": "constant 0 on every run",
    "subZone": "constant empty string on every run",
}


# ★★★ §263 / W2.2b: THE SATNAV PROBE, REDUCED INTO THE SAME FORM. The analyst's choice
# over a second reader: *"one reader, one economy, and the form any future declined-state
# walk lands in."*
#
# ⚠⚠ AND TWO CORPUS FIELDS CANNOT BE PRODUCED HONESTLY FROM IT:
#
#     gt      ABSENT - the probe never recorded GetTime
#     floor   ABSENT - its `f` is FACING in radians (5.32), not a floor
#     t       DIFFERENT - satnav's `t` is ELAPSED seconds from arm, not a wall clock
#
# ★ So `t` is RECONSTRUCTED as `startedAt + elapsed` and labelled as such, and the two
# absent fields are NAMED in the header rather than emitted blank. **A blank column and a
# column nobody could fill look identical downstream**, and the walk would silently treat
# an unfilled floor as "no floor change" rather than "no floor data".
SATNAV_ABSENT = ("gt", "floor")


def satnav_rows(pay):
    """Probe rows -> corpus shape. `od` is rebuilt from the probe's own hd/vd, which it
    measured against the pin it set - so both terms of the pair survive the reduction."""
    import math
    pin = pay.get("pin") or {}
    out = []
    for r in pay.get("rows") or []:
        row = {"x": r.get("px"), "y": r.get("py"), "z": r.get("pz"),
               "mapID": r.get("pm"), "sd": r.get("sd"),
               "ts": r.get("ts"), "tr": r.get("tr"), "t_rel": r.get("t")}
        # ★★★ `od` FROM RAW POSITIONS, not from the probe's hd/vd.
        #
        # ⚠⚠ The probe DECLINES to compute hd/vd across a map boundary - correctly, because
        # a distance to a pin in another coordinate space is not a distance. But taking that
        # decline forward leaves `od` absent on exactly the 57 rows W2.2 exists to test, and
        # the divergence detector then has nothing to disagree with.
        #
        # ★ THE DETECTOR DOES NOT NEED THE DISTANCE TO BE MEANINGFUL, ONLY COMPUTABLE. It is
        # not asserting "you are 4,733 yards away" - it is asserting THESE TWO SOURCES
        # DISAGREE, and the disagreement with the engine's 0.00 is the entire signal.
        if None not in (r.get("px"), r.get("py"), r.get("pz")) and pin.get("x") is not None:
            row["od"] = math.sqrt((r["px"] - pin["x"]) ** 2
                                  + (r["py"] - pin["y"]) ** 2
                                  + (r["pz"] - pin["z"]) ** 2)
        # ★ The probe's own answer kept ALONGSIDE, never instead - so a reader can see that
        # it declined rather than infer it from a gap.
        if r.get("hd") is not None:
            row["probe_hd"], row["probe_vd"] = r.get("hd"), r.get("vd")
        out.append(dict((k, v) for k, v in row.items() if v is not None))
    return out, pin


def reduce_satnav(path, outdir):
    import datetime
    d = json.load(io.open(path, encoding="utf-8"))
    pay = d.get("payload") or {}
    prov = dict(d.get("_provenance") or {})
    hdr = d.get("header") or {}
    rows, pin = satnav_rows(pay)
    if not rows:
        return None

    # ★ Wall clock rebuilt from the header's start plus the row's elapsed. A DERIVATION,
    # and named as one - `tSource` says where it came from so nobody reads it as captured.
    t0 = None
    try:
        t0 = datetime.datetime.strptime(hdr.get("startedAt", ""), "%Y-%m-%d %H:%M:%S")
    except Exception:
        t0 = None
    if t0 is not None:
        base = int(t0.timestamp())
        for r in rows:
            if r.get("t_rel") is not None:
                r["t"] = base + r["t_rel"]

    keys = ["t", "x", "y", "z", "mapID", "sd", "od", "ts", "tr", "t_rel",
            "probe_hd", "probe_vd"]
    head = {
        "_kind": "satnav-corpus",
        "run": hdr.get("task", "satnav"),
        "profile": "satnav-probe",
        "armedAt": hdr.get("startedAt"),
        "testPin": pin,
        "testPinSet": True,
        "fields": keys,
        "rows": len(rows),
        "markers": 0,
        "reducedFrom": os.path.basename(path),
        "absentFields": list(SATNAV_ABSENT),
        "tSource": "reconstructed: header startedAt + row elapsed" if t0 else "ABSENT",
        "_provenanceCovers": "the whole SavedVariables flush, not this run alone",
        "_provenance": prov,
    }
    base_name = os.path.basename(path).replace("__satnav.json", "__satnav")
    p1 = "%s/%s__legs.jsonl" % (outdir, base_name)
    with io.open(p1, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(json.dumps(head, sort_keys=True) + "\n")
        for r in rows:
            fh.write(json.dumps(row_of(r, keys), sort_keys=True) + "\n")
    return {"run": head["run"], "rows": len(rows), "marks": 0, "keys": keys,
            "legs_file": p1, "marks_file": None,
            "raw": prov.get("raw_clone"), "sha": (prov.get("sha256") or "")[:12]}


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

    keys = list(CORE) + [k for k in CARRIED if any(l.get(k) is not None for l in legs)]

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
        # ★ §269: the dungeon's HUMAN name, off the legs rather than invented. It is
        # constant per run (a dungeon is one instance), so it is header material - and
        # without it the view identified a capture only by a numeric mapID.
        "zone": next((l.get("zone") for l in legs if l.get("zone")), None),
        "omittedFields": OMITTED,
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
        # ★ §269: markers carry a tracker reading too, and W5 uses marker positions AS
        # pseudo-beacons - so a marker is exactly where a calibration pair is worth
        # having. They were being dropped here while the legs kept them.
        mk = ("t", "gt", "x", "y", "z", "mapID", "floor", "kind", "n", "dead",
              "killedBy", "killedByUnavailable", "sd", "od", "ts", "mapX", "mapY")
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

    # ★ satnav records join the same sweep - one emitter, one output shape.
    sat = sorted(glob.glob(LANDING + "/records/*__satnav.json"))
    hits = [p for p in sources() + sat if not a.match or a.match.lower() in p.lower()]
    if not hits:
        print("")
        print("   Nothing matched." if a.match else "   No landed runs found.")
        print("")
        return 1

    print("")
    done = 0
    for p in hits:
        r = reduce_satnav(p, outdir) if p.endswith("__satnav.json") else reduce_run(p, outdir)
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
