"""
verify.py - the ASSEMBLE-stage regression harness. Does the assembler still reproduce the
blessed golden outputs from the committed parts? A structured-output machine, READ-ONLY:
re-assemble each golden's BOM from parts/ -> diff the table vs the golden -> CLASSIFY every
diff. Known-inert (an inert `use_*: false` toggle shed) auto-passes; anything else is FLAGGED.

Two regression points, two owners (no temp dirs, no arbitrary data handling):
  - DERIVE (corpus -> parts/) is checked by GIT: re-derive, then `git diff parts/` shows any
    change. parts/ is the committed expected-product; git is its golden.
  - ASSEMBLE (parts -> table) is checked HERE against goldens/ (the only new tracked artifact).
Re-derive stays an explicit step you run when you touch the engine; git shows it on parts/,
then this shows the downstream effect on the assembled output. Retires the manual byte-check.

  py verify.py bless <bomstem>    # run the pipeline, save the assembled table as the golden
  py verify.py                    # verify EVERY golden: re-run its BOM, diff, classify, report
  py verify.py verify <bomstem>   # verify just one

Goldens live in plane/goldens/<bomstem>.golden.json (tracked = the committed reference).
The intelligence-kernel is the FLAG list - a diff the harness can't call inert. Review it;
if it's a wanted improvement, `bless` to move the golden forward.
"""
import contextlib
import glob
import io
import json
import os
import sys

_THIS = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, _THIS)
import assemble as asm

BOMS = os.path.join(_THIS, "boms")
GOLDENS = os.path.join(_THIS, "goldens")
ABSENT = "<absent>"


def _assemble(stem):
    with open(os.path.join(BOMS, stem + ".bom.json"), encoding="utf-8") as f:
        bom = json.load(f)
    with contextlib.redirect_stdout(io.StringIO()):
        return asm.assemble(bom)


def _flatten(obj, prefix=""):
    out = {}
    if isinstance(obj, dict):
        for k, v in obj.items():
            out.update(_flatten(v, ("%s.%s" % (prefix, k)) if prefix else str(k)))
    elif isinstance(obj, list):
        for i, v in enumerate(obj):
            out.update(_flatten(v, "%s[%d]" % (prefix, i)))
    else:
        out[prefix] = obj
    return out


def _classify(path, gval, fval):
    """Known-inert: a `use_*` toggle whose value is False being added or removed - shedding
    (or gaining) an inert touched-off toggle changes nothing about behaviour. Else: FLAG."""
    leaf = path.split(".")[-1].split("[")[0]
    if leaf.startswith("use_") and (gval is False or fval is False) and (gval == ABSENT or fval == ABSENT):
        return "inert"
    return "flag"


def _diff(golden, fresh):
    g, f = _flatten(golden), _flatten(fresh)
    diffs = []
    for k in sorted(set(g) | set(f)):
        gv, fv = g.get(k, ABSENT), f.get(k, ABSENT)
        if gv != fv:
            diffs.append((k, gv, fv, _classify(k, gv, fv)))
    return diffs


def cmd_bless(stem):
    data = _assemble(stem)
    os.makedirs(GOLDENS, exist_ok=True)
    path = os.path.join(GOLDENS, stem + ".golden.json")
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=1, ensure_ascii=False)   # assembler output is deterministic; no sort (mixed int/str keys)
        f.write("\n")
    print("blessed golden: %s  (%d flattened fields)" % (stem, len(_flatten(data))))


def cmd_verify(stems=None):
    if stems is None:
        stems = [os.path.basename(p)[:-len(".golden.json")]
                 for p in sorted(glob.glob(os.path.join(GOLDENS, "*.golden.json")))]
    if not stems:
        print("no goldens - run `verify.py bless <bomstem>` first")
        return 1
    worst = 0                                        # 0 pass, 1 inert-only, 2 flagged
    for stem in stems:
        gpath = os.path.join(GOLDENS, stem + ".golden.json")
        if not os.path.exists(gpath):
            print("  %-32s NO GOLDEN" % stem); worst = max(worst, 2); continue
        golden = json.load(open(gpath, encoding="utf-8"))
        fresh = _assemble(stem)
        diffs = _diff(golden, fresh)
        flags = [d for d in diffs if d[3] == "flag"]
        inert = [d for d in diffs if d[3] == "inert"]
        if not diffs:
            print("  %-32s PASS  (identical to golden)" % stem)
        elif not flags:
            print("  %-32s PASS  (%d inert diff(s) shed - behaviour unchanged)" % (stem, len(inert)))
            worst = max(worst, 1)
            for k, gv, fv, _ in inert:
                print("        inert: %-40s %s -> %s" % (k, gv, fv))
        else:
            print("  %-32s FLAG  (%d for review, %d inert)" % (stem, len(flags), len(inert)))
            worst = max(worst, 2)
            for k, gv, fv, _ in flags:
                print("        FLAG : %-40s %s -> %s" % (k, gv, fv))
    print("\nresult: %s" % ("PASS" if worst == 0 else "PASS (inert-only)" if worst == 1 else "FLAGGED - review needed"))
    return 0 if worst < 2 else 2


def main():
    args = sys.argv[1:]
    if args and args[0] == "bless":
        if len(args) < 2:
            raise SystemExit("usage: verify.py bless <bomstem>")
        cmd_bless(args[1])
        return 0
    if args and args[0] == "verify":
        return cmd_verify(args[1:] or None)
    return cmd_verify(None)


if __name__ == "__main__":
    sys.exit(main())
