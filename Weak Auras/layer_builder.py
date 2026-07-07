"""
layer_builder.py - builds exactly ONE WeakAuras layer (group) at a time
from a class's inventory.py file.

Architecture settled with Battlewrath, 2026-07-06: every class will
eventually get this treatment (Necromancer first; other classes are "a
bridge when we have to consider another" - not built out now). Each
class owns one inventory.py (LAYERS dict, keyed by layer name - "Resources",
"Tier 1 Rotation", "Tier 2", ...), where each layer's slots (coordinates,
options, spell IDs) are plain constants, not code. This module is the one
shared, class-agnostic, layer-agnostic builder that turns any single
layer's slot list into a real import string - it never changes when a
new tier or class is added, only the inventory.py data does.

Deliberately builds ONE layer per call, never the whole class UI at once:
"The complete compile comes later in-game using WeakAuras. (And so we're
not asking the compiler to rebuild the full UI every time.)" - Battlewrath.
Layers get imported and nested/consolidated together live, in WeakAuras'
own UI (matching BUILD_METHOD.md's existing per-tier authoring process),
not pre-merged by this tool. A layer can be a "group" (static membership,
e.g. Resources, Tier 1 Rotation) or a "dynamicgroup" (variable membership,
e.g. a future enemy-cast-tracking layer) - set via that layer's own
"region_type" key; encode_group_import_string itself is agnostic to which.

Usage (CLI):
    python3 layer_builder.py <class_folder> <inventory.py path> <layer name>

Usage (importable):
    from layer_builder import build_layer
    import_string, version, path = build_layer(inventory, "Tier 1 Rotation", class_folder)
"""
import copy
import glob
import importlib.util
import os
import re
import sys

_THIS_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, _THIS_DIR)
import template_filler
import weakaura_codec as wc


# Fields present in RegionTypes/DynamicGroup.lua's own `default` table but
# ABSENT from weakaura_codec.EXAMPLE_GROUP_AURA (which is shaped for a plain
# static "group"). Added 2026-07-09 building the "Minion tracker" capability -
# confirmed by direct source read of DynamicGroup.lua (see build_templates.py's
# minion_presence_icon writeup for the fuller trail). Without this, calling
# build_layer() with region_type="dynamicgroup" silently produced a group
# missing its own reflow behavior entirely (no grow/align/space/etc at all).
DYNAMICGROUP_EXTRA_DEFAULTS = {
    "grow": "DOWN",
    "align": "CENTER",
    "space": 2,
    "stagger": 0,
    "sort": "none",
    "animate": False,
    "radius": 200,
    "rotation": 0,
    "stepAngle": 15,
    "fullCircle": True,
    "arcLength": 360,
    "constantFactor": "RADIUS",
    "useLimit": False,
    "limit": 5,
    "gridType": "RD",
    "centerType": "LR",
    "gridWidth": 5,
    "rowSpace": 1,
    "columnSpace": 1,
}


def _slugify(layer_name):
    """'Tier 1 Rotation' -> 'Tier1_Rotation', matching the filename already
    hand-picked for Tier1_Rotation_v1_import.txt (2026-07-06, built before
    this auto-versioning existed) - squash a space immediately before a
    number onto that number first (so 'Tier 1' becomes 'Tier1', not
    'Tier_1'), then underscore-join everything else. Confirmed against the
    real existing file rather than picked arbitrarily, so _next_version
    actually finds it and continues from v2, not silently restarting at v1
    under a name that looks similar but wouldn't glob-match."""
    squashed = re.sub(r"\s+(\d)", r"\1", layer_name)
    return re.sub(r"[^A-Za-z0-9]+", "_", squashed).strip("_")


def _next_version(class_folder, layer_name):
    """Auto-versioning, matching the existing Resources_vN / Tier1_Rotation_vN
    convention already in use - scans for the highest existing vN for this
    layer's slug and returns the next one (1 if none exist yet)."""
    slug = _slugify(layer_name)
    existing = glob.glob(os.path.join(class_folder, f"{slug}_v*_import.txt"))
    versions = []
    for path in existing:
        m = re.search(rf"{re.escape(slug)}_v(\d+)_import\.txt$", path)
        if m:
            versions.append(int(m.group(1)))
    return (max(versions) + 1) if versions else 1


# Fields on the group aura that describe WHERE it actually sits on screen -
# preserved across rebuilds (see _load_previous_layer_state below). Added
# 2026-07-09 after Battlewrath's real feedback on the Skeletal Archers/Tier 1
# Rotation rebuild: "you moved the slot positions" - root-caused to
# build_layer() always generating a fresh random uid (for the group AND every
# child) and never carrying forward the group's own anchor, so a rebuild of
# an already-live, already-hand-positioned layer looked to WeakAuras like a
# brand new aura landing back at the default screen-center anchor, not an
# update to the existing one. Confirmed this was NOT a coordinate math error -
# the per-slot x/y this project generates (e.g. Tier 1 slot 2 = -64.5, -130)
# already matched ELEMENT_INVENTORY.md's settled mask exactly, both before
# and after the rebuild.
GROUP_ANCHOR_FIELDS = (
    "x", "y", "xOffset", "yOffset",
    "selfPoint", "anchorPoint", "anchorFrameType",
    "anchorFrameFrame", "anchorFrameParent", "parent",
)


def _load_previous_layer_state(class_folder, layer_name):
    """Decode the most recently built version of this layer (if any) so
    build_layer() can carry forward the group's real uid/anchor and each
    still-present child's own uid, instead of generating fresh random ones
    every rebuild (see GROUP_ANCHOR_FIELDS' comment for why this matters).
    Returns (prev_group_or_None, {child_id: child_dict}). Best-effort - if no
    previous version exists, or it fails to decode for any reason, returns
    (None, {}) rather than blocking the build."""
    slug = _slugify(layer_name)
    existing = glob.glob(os.path.join(class_folder, f"{slug}_v*_import.txt"))
    versions = []
    for path in existing:
        m = re.search(rf"{re.escape(slug)}_v(\d+)_import\.txt$", path)
        if m:
            versions.append((int(m.group(1)), path))
    if not versions:
        return None, {}
    _, latest_path = max(versions, key=lambda v: v[0])
    try:
        with open(latest_path) as f:
            prev_group, prev_children = wc.decode_group_import_string(f.read().strip())
    except Exception:
        return None, {}
    return prev_group, {c["id"]: c for c in prev_children if isinstance(c, dict) and "id" in c}


def build_layer(inventory, layer_name, class_folder, write=True):
    """
    inventory: a module (or plain dict) exposing LAYERS - {layer_name: {
        "region_type": "group" | "dynamicgroup" (default "group"),
        "slots": [{"template": <template_filler template name>, "params": {...}}, ...],
        "group_trigger": optional override of the group container's own
            trigger dict (default: an always-true 'Unit Characteristics'
            trigger, matching Resources/Tier 1 Rotation's existing convention -
            a dynamicgroup layer will usually want its own real trigger here).
    }}.
    layer_name: a key into LAYERS.
    class_folder: real filesystem path to write the versioned import file
        into (e.g. .../Necromancer). Not written if write=False.
    Returns (import_string, version, path).
    """
    layers = getattr(inventory, "LAYERS", inventory)
    if layer_name not in layers:
        raise KeyError(f"Unknown layer '{layer_name}'. Known: {sorted(layers)}")
    layer = layers[layer_name]

    # Preserve uid/anchor from the previous build of this SAME layer, if one
    # exists - see GROUP_ANCHOR_FIELDS' comment above for why (without this,
    # every rebuild looked like a brand-new aura to WeakAuras and reset to
    # the default screen-center anchor, discarding any manual in-game
    # repositioning).
    prev_group, prev_children_by_id = _load_previous_layer_state(class_folder, layer_name)

    children = []
    for slot in layer["slots"]:
        child = template_filler.fill_template(
            slot["template"], slot["params"], generate_uid_fn=wc.generate_unique_id
        )
        prev_child = prev_children_by_id.get(child["id"])
        if prev_child and "uid" in prev_child:
            # Same-named child existed in the last build of this layer -
            # keep its real uid so WeakAuras treats this as an update to the
            # existing live aura, not a new one. A genuinely new child (like
            # Skeletal Archers, which had no prior "Tier 1 Rotation" build to
            # match against) keeps the fresh uid fill_template just gave it.
            child["uid"] = prev_child["uid"]
        children.append(child)

    group = copy.deepcopy(wc.EXAMPLE_GROUP_AURA)
    group["id"] = layer_name
    group["uid"] = prev_group["uid"] if prev_group and "uid" in prev_group else wc.generate_unique_id()
    group["regionType"] = layer.get("region_type", "group")
    if group["regionType"] == "dynamicgroup":
        # EXAMPLE_GROUP_AURA is shaped for a static "group" and lacks every
        # DynamicGroup-specific layout field (grow/align/space/etc) - merge
        # in DynamicGroup.lua's own real defaults first, so a dynamicgroup
        # layer always has full reflow behavior even if group_layout below
        # doesn't override every field.
        group.update(copy.deepcopy(DYNAMICGROUP_EXTRA_DEFAULTS))
    if prev_group:
        # Carry forward wherever this group actually lives on screen right
        # now (manual drag/repositioning in WeakAuras' own options UI is
        # never reflected back into inventory.py - it only exists in the
        # last real build/import). Applied BEFORE group_layout below, so an
        # explicit, deliberately-authored override (e.g. Minion tracker's
        # real captured position) always still wins.
        group.update({k: prev_group[k] for k in GROUP_ANCHOR_FIELDS if k in prev_group})
    # Optional per-layer overrides (position, and for a dynamicgroup: grow/
    # align/space/selfPoint/etc) - e.g. matching a real hand-built capture
    # exactly, as with the "Minion tracker" layer's group_layout.
    group.update(layer.get("group_layout", {}))
    group["controlledChildren"] = [c["id"] for c in children]
    group["triggers"] = layer.get(
        "group_trigger",
        {1: {"trigger": {"type": "unit", "event": "Unit Characteristics", "unit": "player"}, "untrigger": {}}},
    )

    import_string = wc.encode_group_import_string(group, children)

    version = _next_version(class_folder, layer_name)
    slug = _slugify(layer_name)
    filename = f"{slug}_v{version}_import.txt"
    path = os.path.join(class_folder, filename)
    if write:
        with open(path, "w") as f:
            f.write(import_string)

    return import_string, version, path


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("usage: python3 layer_builder.py <class_folder> <inventory.py path> <layer name>")
        sys.exit(1)
    class_folder, inventory_path, layer_name = sys.argv[1], sys.argv[2], sys.argv[3]
    spec = importlib.util.spec_from_file_location("inventory", inventory_path)
    inventory = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(inventory)
    import_string, version, path = build_layer(inventory, layer_name, class_folder)
    print(f"Wrote {path} (v{version}, {len(import_string)} chars)")
