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

    children = []
    for slot in layer["slots"]:
        child = template_filler.fill_template(
            slot["template"], slot["params"], generate_uid_fn=wc.generate_unique_id
        )
        children.append(child)

    group = copy.deepcopy(wc.EXAMPLE_GROUP_AURA)
    group["id"] = layer_name
    group["uid"] = wc.generate_unique_id()
    group["regionType"] = layer.get("region_type", "group")
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
