"""
mask_validate.py - READ-ONLY validator for the mask -> assembly pipeline.

Checks a class's inventory.py against the derived mask JSON(s) + the
capability REGISTRY, and REPORTS. It writes nothing, imports no encoder, and
touches no build path - its whole job is to surface drift/mismatches before
they reach an import string or the game.

Three tiers (settled with Battlewrath):
  HARD  - would block assembly: unknown template (capability doesn't exist),
          malformed spell id (would break the WA import), element larger than
          its family's spatial budget.
  WARN  - assembles but flagged: a well-formed spell id absent from every
          index (correct in-game, back-fill the index - the pressure loop);
          region mismatch; element position matches no mask family.
  INFO  - context, not a problem: a family the mask itself flags "disputed"
          (its Template_shadow capture is stale vs resources_base.py), or a
          layer that needs its own mask identity developed (rule: a mask must
          exist before its content assembles).

POSITIONAL REVERSE-MATCH: today's inventories carry raw x/y, not family ids
(family-referencing inventories are phase 2 - the assembler). So this tool
reverse-matches each element to a family by position. A disputed family is
compared against its LIVE value (resources_base.py), so a bar sitting at the
live geometry reads as INFO ("matches live; mask capture stale"), not a
false drift error.

Usage:
    py mask_validate.py Necromancer
"""
import glob
import importlib.util
import json
import os
import sys

_THIS_DIR = os.path.dirname(os.path.abspath(__file__))
_PROJECT_ROOT = os.path.dirname(_THIS_DIR)
sys.path.insert(0, _THIS_DIR)
sys.path.insert(0, os.path.join(_THIS_DIR, "Tiers"))
sys.path.insert(0, os.path.join(_THIS_DIR, "Templates"))
from build_templates import REGISTRY, FRAGMENTS  # capability index (thin view)

MASKS_DIR = os.path.join(_THIS_DIR, "masks")
EXACT = 0.01     # px: treat as an exact position match
NEAR = 2.0       # px: treat as drift (near a family but off by a hair)

# Param keys whose values are real spell IDs (ints). Name-based option lists
# (missing_state_option_names, option_names) are deliberately excluded - they
# resolve by name in-game, not by ID.
SPELL_ID_KEYS = ("spell_id", "fallback_icon", "guardian_aura_id")


# --------------------------------------------------------------------------- loaders
def load_masks():
    masks = {}
    for path in glob.glob(os.path.join(MASKS_DIR, "*.mask.json")):
        m = json.load(open(path))
        masks[m["mask_id"]] = m
    if not masks:
        raise SystemExit("No masks found - run `py mask_derive.py` first.")
    return masks


def load_inventory(class_name):
    path = os.path.join(_THIS_DIR, class_name, "inventory.py")
    if not os.path.exists(path):
        raise SystemExit(f"No inventory at {path}")
    spec = importlib.util.spec_from_file_location(f"{class_name}_inventory", path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return getattr(mod, "LAYERS")


def load_index_ids(class_name):
    """Harvest known spell IDs for the class from whatever index files exist.
    Warn-level only, so a broad harvest (any int under a spell/id-ish key) is
    fine - the point is 'have we seen this ID anywhere', not exhaustiveness."""
    ids = set()
    candidates = [
        os.path.join(_PROJECT_ROOT, "Outputs", "weakaura_index", f"{class_name.lower()}_weakaura_index.json"),
        os.path.join(_PROJECT_ROOT, "Outputs", "live_reference", f"{class_name.lower()}_live_reference.json"),
    ]
    found = []
    for path in candidates:
        if os.path.exists(path):
            found.append(os.path.basename(path))
            _harvest_ids(json.load(open(path)), ids)
    return ids, found


def _harvest_ids(node, ids):
    if isinstance(node, dict):
        for k, v in node.items():
            if isinstance(v, int) and ("spell" in k.lower() or k.lower() == "id") and v > 0:
                ids.add(v)
            else:
                _harvest_ids(v, ids)
    elif isinstance(node, list):
        for v in node:
            _harvest_ids(v, ids)


# --------------------------------------------------------------------------- checks
def effective_geom(fam):
    """Anchor + budget of a geometry-computed family (mask_build.py schema)."""
    ax, ay = fam["anchor"]
    b = fam["budget"]
    return ax, ay, b["w"], b["h"], fam["region"]


def classify_position(px, py, families):
    if px is None or py is None:
        return None, "no_position"
    best_fid, best_fam, best_d = None, None, None
    for fid, fam in families:
        ex, ey, *_ = effective_geom(fam)
        d = abs(ex - px) + abs(ey - py)
        if best_d is None or d < best_d:
            best_fid, best_fam, best_d = fid, fam, d
    ex, ey, *_ = effective_geom(best_fam)
    if abs(ex - px) <= EXACT and abs(ey - py) <= EXACT:
        return (best_fid, best_fam), "exact"
    if best_d <= NEAR:
        return (best_fid, best_fam), "drift"
    return None, "none"


def validate(class_name):
    masks = load_masks()
    layers = load_inventory(class_name)
    index_ids, index_files = load_index_ids(class_name)

    families = []
    for mid, m in masks.items():
        for fid, fam in m["families"].items():
            families.append((f"{mid}:{fid}", fam))

    print(f"== mask validation: {class_name} ==")
    print(f"masks: {', '.join(masks)}  |  capability templates: {len(REGISTRY)}  "
          f"fragments: {len(FRAGMENTS)}")
    print(f"index files: {', '.join(index_files) or '(none found)'}  "
          f"({len(index_ids)} known spell ids)\n")

    hard, warn, info = [], [], []

    for layer_name, layer in layers.items():
        region_type = layer.get("region_type", "group")
        is_dynamic = region_type == "dynamicgroup"
        print(f"-- layer '{layer_name}' ({region_type}) --")
        for slot in layer["slots"]:
            template = slot["template"]
            params = slot["params"]
            name = params.get("name", "?")
            flags = []

            # capability existence
            if template not in REGISTRY:
                hard.append((layer_name, name, f"unknown template '{template}'"))
                flags.append("HARD unknown-template")
                print(f"   {name:26s} {template:24s} {' '.join(flags)}")
                continue
            tmpl_region = REGISTRY[template][0]["region_type"]

            # position / family
            if is_dynamic:
                flags.append("INFO anchored-dynamicgroup")
                info.append((layer_name, name, "dynamicgroup - needs its own mask identity (develop mask first)"))
            else:
                match, status = classify_position(params.get("x"), params.get("y"), families)
                if status == "exact":
                    fid, fam = match
                    flags.append(f"ok exact={fid} [{fam.get('provenance', '?')}]")
                    # region check
                    _, _, ew, eh, ereg = effective_geom(fam)
                    if tmpl_region != ereg:
                        warn.append((layer_name, name, f"region {tmpl_region} != family {ereg} ({fid})"))
                        flags.append("WARN region")
                    # budget fit
                    w, h = params.get("width"), params.get("height")
                    if w is not None and ew is not None and w > ew + EXACT:
                        hard.append((layer_name, name, f"width {w} > budget {ew} ({fid})"))
                        flags.append("HARD over-budget-w")
                    if h is not None and eh is not None and h > eh + EXACT:
                        hard.append((layer_name, name, f"height {h} > budget {eh} ({fid})"))
                        flags.append("HARD over-budget-h")
                elif status == "drift":
                    fid, fam = match
                    warn.append((layer_name, name, f"position ({params.get('x')},{params.get('y')}) drifts from nearest family {fid}"))
                    flags.append(f"WARN drift~{fid}")
                elif status == "none":
                    warn.append((layer_name, name, f"position ({params.get('x')},{params.get('y')}) matches no mask family"))
                    flags.append("WARN unmasked")
                else:  # no_position
                    flags.append("INFO no-position")

            # spell ids
            for key in SPELL_ID_KEYS:
                if key not in params:
                    continue
                val = params[key]
                if not (isinstance(val, int) and val > 0):
                    hard.append((layer_name, name, f"malformed {key}={val!r} (would break import)"))
                    flags.append(f"HARD bad-{key}")
                elif val not in index_ids:
                    warn.append((layer_name, name, f"{key}={val} not in any index (verify + back-fill)"))
                    flags.append(f"WARN unindexed-{key}")

            print(f"   {name:26s} {template:24s} {' '.join(flags)}")
        print()

    # summary
    print("== summary ==")
    print(f"HARD {len(hard)}  |  WARN {len(warn)}  |  INFO {len(info)}\n")
    for tier, items in (("HARD", hard), ("WARN", warn), ("INFO", info)):
        if items:
            print(f"{tier}:")
            for layer_name, name, msg in items:
                print(f"  [{layer_name}] {name}: {msg}")
            print()
    return 1 if hard else 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("usage: py mask_validate.py <ClassName>")
        sys.exit(2)
    sys.exit(validate(sys.argv[1]))
