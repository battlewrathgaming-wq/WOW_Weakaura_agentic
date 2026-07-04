"""
Necromancer/inventory.py - this class's own slot data, per layer, for
layer_builder.py to consume. Plain constants only (coordinates, options,
spell IDs) - no fill/encode logic here; that's layer_builder.py's job,
shared across every class and layer. See ../layer_builder.py's own
docstring for the full architecture rationale (settled with Battlewrath,
2026-07-06).

Layer numbering here tracks BUILD ORDER, not each layer's in-game tier
number - "Resources" (+ the still-live Template_shadow.py placeholder
scaffolding it superseded) is layer 1; "Tier 1 Rotation" is layer 2, even
though it corresponds to HUD_DESIGN.md's own "Rotation" tier - the two
numbering schemes are allowed to diverge.
"""

ACCENT_COLOR = [0.2706, 0.8588, 0.6118, 1.0]  # theme.json's accent_rgba

# Necromancer's confirmed power types (slot_assignment.md) - Mana=0, Runic Power=6.
POWERTYPE_MANA = 0
POWERTYPE_RUNIC_POWER = 6

LAYERS = {
    # ------------------------------------------------------------------
    # Layer 1: Resources (Mana, Runic Power, Cast Bar (+ backing), Swing
    # Timer (+ backing)) - NOT YET RETROFITTED into this inventory format.
    # Built through 13 iterative ad-hoc sessions before this file existed
    # (see Necromancer/Resources_v13_import.txt, the current real output,
    # and BUILD_METHOD.md/slot_assignment.md for the full history). Left
    # as a placeholder here rather than reverse-engineered from v13 right
    # now, to avoid silently drifting the live, working build while
    # reconstructing its exact params - a deliberate, flagged follow-up,
    # not an oversight.
    # ------------------------------------------------------------------
    # "Resources": {"region_type": "group", "slots": [...]},  # TODO: backfill

    # ------------------------------------------------------------------
    # Layer 2: Tier 1 Rotation - Necromancer's first three real abilities
    # at this level (2026-07-06). Positions from the settled mask
    # (Template_shadow_v0.14_import.txt's "Tier 1 slot Rotation"/"slot 2"/
    # "slot 3" - six slots exist total, three used so far). Costs pulled
    # from db.ascension.gg (2026-07-06): Lichfrost/Crypt Swarm cost 10% of
    # base mana each (checked via the Power trigger's percentpower field);
    # Command: Undead costs a flat 30 Runic Power (checked via the raw
    # power field), matching the 30 RP figure already independently
    # confirmed in slot_assignment.md. Slot-to-ability ordering (Lichfrost
    # -> Crypt Swarm -> Command: Undead) was an agent proposal, not
    # dictated by any real data - Battlewrath confirmed the first build,
    # revisit here if that ordering ever changes.
    # ------------------------------------------------------------------
    "Tier 1 Rotation": {
        "region_type": "group",
        "slots": [
            {
                "template": "cooldown_tracker_icon",
                "params": {
                    "name": "Lichfrost",
                    "spell_id": 501969,
                    "x": -107.5,
                    "y": -130,
                    "accent_color": ACCENT_COLOR,
                    "power_threshold": {
                        "powertype": POWERTYPE_MANA,
                        "cost": 10,
                        "cost_is_percent": True,
                    },
                },
            },
            {
                "template": "cooldown_tracker_icon",
                "params": {
                    "name": "Crypt Swarm",
                    "spell_id": 500965,
                    "x": -64.5,
                    "y": -130,
                    "accent_color": ACCENT_COLOR,
                    "power_threshold": {
                        "powertype": POWERTYPE_MANA,
                        "cost": 10,
                        "cost_is_percent": True,
                    },
                },
            },
            {
                "template": "cooldown_tracker_icon",
                "params": {
                    "name": "Command: Undead",
                    "spell_id": 504868,
                    "x": -21.5,
                    "y": -130,
                    "accent_color": ACCENT_COLOR,
                    "power_threshold": {
                        "powertype": POWERTYPE_RUNIC_POWER,
                        "cost": 30,
                        "cost_is_percent": False,
                        "include_afford_glow": True,
                    },
                },
            },
        ],
    },
}
