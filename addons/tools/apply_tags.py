"""apply_tags.py - insert RULING/FACT/OPEN tags from a spec, with the anchor as proof.

★★ WHY A TOOL. Tagging the barren files means ~60 insertions across nine addons from
an auditor's `file:line` list. Two things make that unsafe by hand:

  1. Every insertion SHIFTS the lines below it, so a list of line numbers is wrong the
     moment you use it. Applied bottom-up, per file, it is not.
  2. A line number alone is not evidence. An auditor reporting `:139` may be off by
     three, or the file may have moved since - and a tag landing on the wrong block is
     worse than no tag, because it asserts something about code it does not govern.

★★★ SO THE ANCHOR IS THE PROOF. Every spec entry carries a substring that MUST appear
in the target block. Not found within the window -> that entry is REFUSED and named,
and nothing in that file is written. The line number only narrows the search; the
anchor is what authorises the write.

⚠ It refuses the whole FILE on any miss rather than applying the good ones. A partial
apply leaves a spec you can no longer re-run, and the re-run is what makes this safe.

Usage:
    py addons\\tools\\apply_tags.py <spec.json>
    py addons\\tools\\apply_tags.py <spec.json> --dry     # report, write nothing

Spec: [{ "file": "...", "line": 139, "anchor": "text that must be there",
          "tag": "-- ★★ FACT: <headline>", "body": ["optional", "extra", "lines"] }]
"""
import argparse
import io
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent
WINDOW = 6          # lines either side of the claimed line to search for the anchor


def apply(spec, dry=False):
    by_file = {}
    for e in spec:
        by_file.setdefault(e["file"], []).append(e)

    total, refused = 0, []
    for rel, entries in sorted(by_file.items()):
        p = REPO / rel
        if not p.exists():
            refused.append((rel, "-", "FILE NOT FOUND"))
            continue
        raw = io.open(p, encoding="utf-8", newline="").read()
        nl = "\r\n" if "\r\n" in raw else "\n"
        lines = raw.split(nl) if nl == "\r\n" else raw.split("\n")

        # Resolve every anchor FIRST. One miss refuses the file, so a spec stays
        # re-runnable rather than half-applied.
        resolved, bad = [], False
        for e in entries:
            want, at = e["anchor"], e["line"] - 1
            lo, hi = max(0, at - WINDOW), min(len(lines), at + WINDOW + 1)
            hit = next((i for i in range(lo, hi) if want in lines[i]), None)
            if hit is None:
                refused.append((rel, e["line"], "ANCHOR NOT FOUND: " + want[:52]))
                bad = True
            else:
                resolved.append((hit, e))
        if bad:
            continue

        # Bottom-up, so earlier insertions cannot move later targets.
        for hit, e in sorted(resolved, key=lambda r: -r[0]):
            block = [e["tag"]] + list(e.get("body") or [])
            indent = lines[hit][:len(lines[hit]) - len(lines[hit].lstrip())]
            lines[hit:hit] = [indent + b for b in block]
            total += 1

        if not dry:
            io.open(p, "w", encoding="utf-8", newline="").write(nl.join(lines))
        print("  %-44s %d tag(s)%s" % (rel, len(resolved), "  (dry)" if dry else ""))

    if refused:
        print("\n⚠ REFUSED - nothing written for these files:")
        for rel, ln, why in refused:
            print("    %-40s :%-6s %s" % (rel, ln, why))
    print("\n%d tag(s) %s, %d refusal(s)" % (total, "would apply" if dry else "applied",
                                             len(refused)))
    return 1 if refused else 0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("spec")
    ap.add_argument("--dry", action="store_true")
    a = ap.parse_args()
    spec = json.loads(io.open(a.spec, encoding="utf-8").read())
    return apply(spec, a.dry)


if __name__ == "__main__":
    sys.exit(main())
