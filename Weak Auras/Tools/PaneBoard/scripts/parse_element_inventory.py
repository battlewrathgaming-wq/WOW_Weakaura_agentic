"""parse_element_inventory.py - read-only bridge from ELEMENT_INVENTORY.md's
markdown tables into Pane Board's mask overlay (see paneBoard.js's
listMaskSlots()).

Purpose: ELEMENT_INVENTORY.md is, by its own docstring, "a markdown
document, not code - nothing reads it programmatically." This script is
the first thing that does, so the mask overlay's numbers can never drift
from the one documented source of truth for slot position/size. It only
ever READS this file and prints one JSON object to stdout - it never
writes anything, and it has no relationship to the real build pipeline
(Templates/build_templates.py, layer_builder.py, Tiers/resources_base.py
are all untouched by this).

Parsing approach: every real data row in every "## Row X" table looks
like `| Element ID | x | y | w | h | Region |` (6 columns, Row A/B) or the
same plus `| Expected function |` (7 columns, every other row) - rather
than hand-matching each table's exact column count, this scans every line
starting with "|" and keeps it only if columns 2-5 parse as numbers. That
one heuristic transparently skips header rows ("Element ID"/"x"/"y"/...)
and separator rows ("---"/"---"/...) without needing to special-case
either, and works unchanged if a future row's table gains/drops the
optional 7th column.

Usage: python3 parse_element_inventory.py
  Reads ELEMENT_INVENTORY.md from the project root (three levels up from
  this script - Tools/PaneBoard/scripts/ -> Weak Auras root), same
  relationship export_inventory.py already uses for class inventory.py
  files.

Output shape (single JSON object on stdout):
{
  "slots": [
    {
      "row": "Row A - Proc / Condition (Tier 5)",
      "id": "Tier 5 slot Proc",
      "x": -107.5, "y": -105, "w": 40, "h": 20,
      "regionType": "icon",
      "expectedFunction": ""
    },
    ...
  ]
}

On error, prints {"error": "<message>"} and exits 1 - paneBoard.js checks
for this key before treating stdout as a real result.
"""

import json
import os
import sys


def parse_element_inventory(path):
    slots = []
    current_row_label = None
    with open(path, encoding="utf-8") as f:
        lines = f.readlines()
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("## "):
            current_row_label = stripped[3:].strip()
            continue
        if not stripped.startswith("|"):
            continue
        cells = [cell.strip() for cell in stripped.strip("|").split("|")]
        if len(cells) < 6:
            continue
        element_id, x_raw, y_raw, w_raw, h_raw, region = cells[0:6]
        expected_function = cells[6] if len(cells) >= 7 else ""
        try:
            x = float(x_raw)
            y = float(y_raw)
            w = float(w_raw)
            h = float(h_raw)
        except ValueError:
            # Header row ("x", "y", ...) or separator row ("---", "---",
            # ...) - not a real data row, skip without erroring.
            continue
        slots.append({
            "row": current_row_label,
            "id": element_id,
            "x": x,
            "y": y,
            "w": w,
            "h": h,
            "regionType": region,
            "expectedFunction": expected_function,
        })
    return slots


def main():
    this_dir = os.path.dirname(os.path.abspath(__file__))
    # this_dir = Tools/PaneBoard/scripts -> Weak Auras root is 3 levels up.
    project_root = os.path.abspath(os.path.join(this_dir, "..", "..", ".."))
    inventory_path = os.path.join(project_root, "ELEMENT_INVENTORY.md")

    if not os.path.isfile(inventory_path):
        print(json.dumps({"error": f"ELEMENT_INVENTORY.md not found at {inventory_path}"}))
        sys.exit(1)

    try:
        slots = parse_element_inventory(inventory_path)
    except Exception as error:  # noqa: BLE001 - surface any parse failure verbatim to the caller
        print(json.dumps({"error": f"failed to parse ELEMENT_INVENTORY.md: {error}"}))
        sys.exit(1)

    if not slots:
        print(json.dumps({"error": "ELEMENT_INVENTORY.md parsed but produced zero slots - check its table format hasn't changed"}))
        sys.exit(1)

    print(json.dumps({"slots": slots}))


if __name__ == "__main__":
    main()
