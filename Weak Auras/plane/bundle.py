"""
bundle.py - the flat-group ASSEMBLER (the group layer over the single-aura chain).

Bundles N child auras into ONE WeakAuras GROUP import string. NOT the deprecated `assemble.py` (parts/BOM lineage) -
this builds ONLY on the current proven pipeline: each child runs the single-aura chain (expand -> fill -> bounce), then
the codec's group encode bundles them. A THIN wrapper - bundle, never mutate (live-proven 2026-07-13, both group types,
zero per-aura mutation on import).

FLAT groups only. WA rebuilds child wiring from the `c` list on import (version 1421); the codec's
`encode_group_import_string` auto-sets `controlledChildren`. NESTED (2-level) is unbuilt - hand-group flat groups
in-game for a per-class pack (the codec's documented path).

  bundle(manifest_dict) -> group import string
  py bundle.py <manifest.json>          -> the group import string on stdout

manifest:
  { "group":    { "id": <str>, "type": "dynamicgroup"|"group" (default dynamicgroup), "uid": <optional; else minted> },
    "children": [ <child docket path, relative to plane/>, ... ] }   # children in group order
"""
import json
import os
import sys

_THIS = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(_THIS))       # Weak Auras/  (for weakaura_codec)
sys.path.insert(0, _THIS)
import expand
import fill
import reconcile as rec
import weakaura_codec as wc


def _member_aura(docket):
    """one child docket -> a bounced aura, through the proven single-aura chain. A reasoning-docket (triggers lack
    `declare`) is expanded first; a full docket goes straight to fill. bundle NEVER mutates the result."""
    trigs = docket.get("triggers") or []
    reasoning = bool(trigs) and isinstance(trigs[0], dict) and "declare" not in trigs[0]
    full = expand.expand(docket) if reasoning else docket
    return rec.bounce(fill.fill(full))


def _load_child(path):
    p = path if os.path.isabs(path) else os.path.join(_THIS, path)
    return json.load(open(p, encoding="utf-8"))


def bundle(manifest):
    g = manifest["group"]
    children = [_member_aura(_load_child(p)) for p in manifest["children"]]

    ids = [c.get("id") for c in children]
    uids = [c.get("uid") for c in children]
    # identity hygiene: a shared child uid = one aura silently wins on import (codec's own war story). ids must be unique too.
    if len(set(ids)) != len(ids):
        sys.exit("bundle: duplicate child id(s): %s" % sorted({x for x in ids if ids.count(x) > 1}))
    if len(set(uids)) != len(uids):
        sys.exit("bundle: duplicate child uid(s) - would collide on import: %s" % sorted({x for x in uids if uids.count(x) > 1}))

    parent = rec.bounce({
        "id": g["id"],
        "uid": g.get("uid") or wc.generate_unique_id(),      # provided -> use; blank -> mint
        "regionType": g.get("type", "dynamicgroup"),
        "internalVersion": fill._internal_version(),
    })
    s = wc.encode_group_import_string(parent, children)

    # verify: decode the string back; the group must round-trip its members + controlledChildren exactly.
    d, ch = wc.decode_group_import_string(s)
    if [c.get("id") for c in ch] != ids or (d.get("controlledChildren") or []) != ids:
        sys.exit("bundle: group round-trip mismatch (children/controlledChildren != authored)")
    return s


def main():
    if len(sys.argv) < 2:
        sys.exit("usage: py bundle.py <manifest.json>")
    manifest = json.load(open(sys.argv[1], encoding="utf-8"))
    sys.stdout.write(bundle(manifest) + "\n")


if __name__ == "__main__":
    main()
