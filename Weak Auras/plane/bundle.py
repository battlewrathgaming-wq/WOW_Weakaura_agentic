"""
bundle.py - the flat-group ASSEMBLER (the group layer over the single-aura chain).

Bundles N child auras into ONE WeakAuras GROUP import string. NOT the deprecated `assemble.py` (parts/BOM lineage) -
this builds ONLY on the current proven pipeline. The GROUP is a FIRST-CLASS aura: its docket runs the SAME chain as the
children (expand -> fill -> bounce), then the codec's group encode wraps them. bundle CONSTRUCTS NOTHING itself - it just
wraps produced auras (live-proven 2026-07-13, both group types, zero per-aura mutation on import).

FLAT groups only. WA rebuilds child wiring from the `c` list on import (version 1421); the codec's
`encode_group_import_string` auto-sets `controlledChildren`. NESTED (2-level) is unbuilt - hand-group flat groups
in-game for a per-class pack (the codec's documented path).

  bundle(manifest_dict) -> group import string
  py bundle.py <manifest.json>          -> the group import string on stdout

manifest:
  { "group":    <group docket: { "id", "region"|"type" (default dynamicgroup), "uid"? (else minted),
                                  + authored arrangement e.g. "grow","align","sort"... }>,
    "children": [ <child docket path, relative to plane/>, ... ] }   # children in group order
  Authored arrangement flows through expand (a non-default grow gets its coupled selfPoint injected automatically).
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
    """ANY docket -> a bounced aura, through the proven chain (expand -> fill -> bounce). A reasoning-docket (triggers
    lack `declare`) OR a group (region is a group type - arrangement/coupling live in expand) goes through expand; a
    full leaf docket goes straight to fill. bundle NEVER mutates the result. The GROUP is a first-class citizen here -
    same path as any child, no hand-construction."""
    trigs = docket.get("triggers") or []
    reasoning = bool(trigs) and isinstance(trigs[0], dict) and "declare" not in trigs[0]
    is_group = docket.get("region") in ("dynamicgroup", "group")
    full = expand.expand(docket) if (reasoning or is_group) else docket
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

    # The group is an aura too: run its docket through the SAME chain as the children (no hand-construction).
    # `type` is the legacy manifest key for the group region; map it to `region`. expand mints uid if absent.
    group_docket = dict(g)
    group_docket["region"] = g.get("region") or g.get("type", "dynamicgroup")
    group_docket.pop("type", None)
    parent = _member_aura(group_docket)
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
