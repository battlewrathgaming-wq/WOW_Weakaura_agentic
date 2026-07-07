"""export_inventory.py - read-only bridge from a class's inventory.py into
Pane Board's importer (see paneBoard.js's importClassLayout()).

Purpose: let Pane Board propagate a board FROM the already-shipped
inventory.py data, instead of a human manually redrawing panes to match
what's already built. This script only ever READS inventory.py (via
importlib, the same mechanism layer_builder.py already uses to consume it)
and prints one JSON object to stdout - it never writes anything, and it is
not part of the real build pipeline (build_templates.py / layer_builder.py
/ template_filler.py are untouched by this; a Pane Board import can never
feed back into the real WeakAuras export path).

Usage: python3 export_inventory.py <ClassName>
  <ClassName> must be a folder directly under the Weak Auras project root
  that contains its own inventory.py (e.g. "Necromancer", "Reaper").

Output shape (single JSON object on stdout):
{
  "class_name": "Necromancer",
  "layers": [
    {
      "layer": "Tier 1 Rotation",
      "region_type": "group",
      "group_layout": null,
      "template": "cooldown_tracker_icon",
      "params": {"name": "Command: Undead", "spell_id": 504868, "x": -21.5, "y": -130, ...}
    },
    ...
  ]
}

On error, prints {"error": "<message>"} and exits 1 - paneBoard.js checks
for this key before treating stdout as a real result.
"""

import importlib.util
import json
import os
import sys


def main():
    if len(sys.argv) != 2:
        print(json.dumps({"error": "usage: export_inventory.py <ClassName>"}))
        sys.exit(1)

    class_name = sys.argv[1]
    if not class_name or any(ch in class_name for ch in ("/", "\\", "..")):
        print(json.dumps({"error": f"invalid class name: {class_name!r}"}))
        sys.exit(1)

    this_dir = os.path.dirname(os.path.abspath(__file__))
    # this_dir = Tools/PaneBoard/scripts -> Weak Auras root is 3 levels up.
    project_root = os.path.abspath(os.path.join(this_dir, "..", "..", ".."))
    inventory_path = os.path.join(project_root, class_name, "inventory.py")

    if not os.path.isfile(inventory_path):
        print(json.dumps({"error": f"no inventory.py found for class '{class_name}' (looked at {inventory_path})"}))
        sys.exit(1)

    try:
        spec = importlib.util.spec_from_file_location(f"_pane_board_import_{class_name}", inventory_path)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
    except Exception as error:  # noqa: BLE001 - surface any import-time failure verbatim to the caller
        print(json.dumps({"error": f"failed to import {inventory_path}: {error}"}))
        sys.exit(1)

    layers = getattr(module, "LAYERS", None)
    if not isinstance(layers, dict):
        print(json.dumps({"error": f"{inventory_path} has no LAYERS dict"}))
        sys.exit(1)

    out_layers = []
    for layer_name, layer in layers.items():
        if not isinstance(layer, dict):
            continue
        region_type = layer.get("region_type", "group")
        group_layout = layer.get("group_layout")
        slots = layer.get("slots", [])
        for slot in slots:
            if not isinstance(slot, dict):
                continue
            out_layers.append({
                "layer": layer_name,
                "region_type": region_type,
                "group_layout": group_layout,
                "template": slot.get("template"),
                "params": slot.get("params", {}),
            })

    print(json.dumps({"class_name": class_name, "layers": out_layers}))


if __name__ == "__main__":
    main()
