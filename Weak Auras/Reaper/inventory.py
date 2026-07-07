"""
Reaper/inventory.py - this class's own slot data, per layer, for
layer_builder.py to consume. Plain constants only - see
Necromancer/inventory.py's own docstring / ../layer_builder.py's docstring
for the full architecture rationale (unchanged here, just a second class
consuming the same shared pipeline).

Reaper is its own class, not a Necromancer spec - confirmed live via a
real captured WeakAuras Load-tab value ("class.single": "REAPER"),
2026-07-09. See BUILD_METHOD.md for the full context on why this folder
exists now.
"""

import os
import sys

_THIS_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(_THIS_DIR, "..", "Tiers"))
import resources_base as rb

ACCENT_COLOR = [0.0392, 0.5294, 0.4196, 1.0]  # theme.json's accent_rgba (#0a876b)

# Reaper's confirmed power types - Runic Power=6, shared with Necromancer
# (same standard WoW PowerType enum, Tiers/resources_base.py). Reaper has
# no Mana slot at all (per Battlewrath: "this class only uses souls and
# runic power") - that vacated address is where Soul Fragment lives
# instead, at CLASS_RESOURCE_POS.
POWERTYPE_RUNIC_POWER = 6

# Soul Fragment's own real captured barColor (Necromancer/
# _soulfrag_prototype_raw.txt, decoded via weakaura_codec.py) - a muted
# teal-green, close to but deliberately NOT swapped for Reaper's own
# theme.json accent (#0a876b / [0.0392, 0.5294, 0.4196, 1.0]) - this is
# the real, live-tested value Battlewrath's own prototype used, kept as
# evidenced fact rather than re-derived from the theme color. See
# spell_index.md's "Soul Fragment" entry for the full field-by-field trail.
SOUL_FRAGMENT_BAR_COLOR = [0.09019607843137255, 0.580392156862745, 0.43137254901960786, 1]

# Runic Power's own recolor - NOT yet independently captured for Reaper
# specifically (Necromancer's own Runic Power recolor, #21E8FF, is reused
# here since both classes' real captures use the same cyan - unconfirmed
# whether this was a deliberate per-class choice or WeakAuras' own
# clipboard/copy-paste carrying the color across, since Battlewrath built
# both in the same era). Flag before assuming this is permanent if a
# distinct Reaper-only recolor is ever captured.
RUNIC_POWER_BAR_COLOR = [0.12941176470588234, 0.9098039215686274, 1, 1]

LAYERS = {
    # ------------------------------------------------------------------
    # Layer 1: Resources. Soul Fragment occupies the CLASS_RESOURCE_POS
    # slot that Mana fills for Necromancer - Reaper has no Mana bar at all
    # (Battlewrath: "this class only uses souls and runic power"). Runic
    # Power / Cast Bar / Swing Timer / the divider strip are all built via
    # Tiers/resources_base.py's shared builders, same mechanism already
    # live-tested for Necromancer's own Resources tier (Resources_v14_
    # import.txt) - no re-derivation, per this project's 3-layer
    # architecture (see resources_base.py's own docstring).
    #
    # Soul Fragment itself is wholly bespoke (no base-layer entry exists
    # for it - it's not a standard WoW power type), built via the
    # newly-formalized buff_uptime_aurabar template with show_when_missing
    # (Battlewrath's own live-tested "anti statement" footprint fix, "Yes
    # that fixed it") and show_stacks (requested, "Time remaining on soul
    # fragment + stack count" - not yet independently live-tested, though
    # its underlying state.stacks mechanism is already proven on
    # minion_presence_icon).
    # ------------------------------------------------------------------
    "Resources": {
        "region_type": "group",
        "slots": [
            {
                "template": "buff_uptime_aurabar",
                "params": {
                    "name": "Soul Fragment",
                    "spell_id": 805077,
                    **rb.CLASS_RESOURCE_POS,
                    "bar_color": SOUL_FRAGMENT_BAR_COLOR,
                    "show_when_missing": True,
                    "show_stacks": True,
                },
            },
            rb.resource_slot("Runic Power", POWERTYPE_RUNIC_POWER, rb.CLASS_ENERGY_POS, bar_color=RUNIC_POWER_BAR_COLOR),
            rb.cast_bar_backing_slot(),
            rb.cast_bar_slot(),
            rb.swing_timer_backing_slot(),
            rb.swing_timer_slot(),
            rb.divider_strip_slot(color=ACCENT_COLOR),
        ],
    },
}
