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
    # Layer 2: Tier 1 Rotation. Positions from the settled mask
    # (Template_shadow_v0.14_import.txt's "Tier 1 slot Rotation"/"slot 2"/
    # "slot 3" - six slots exist total).
    #
    # PARED DOWN 2026-07-06 (later same day) to just Command: Undead, per
    # Battlewrath's explicit call to stop over-committing: "getting the
    # more up to date rotation bar up to date. Paired down to just the
    # command:undead... proving the UI rather than trying to build it all
    # outright." Context: Battlewrath is level 10 on a server that's been
    # up one day - most of the abilities this project had been scoping
    # (Crypt Swarm, the wider 23-ability class audit) aren't even reachable
    # yet, and the honest priority right now is validating the HUD
    # mechanism itself on the one real, in-use ability, not building out
    # the full kit ahead of actually playing it.
    #   - LICHFROST (501969) - stays dropped (see prior revision below -
    #     confirmed pure Runic Power builder via Ice Barrage).
    #   - CRYPT SWARM (500965) - DROPPED this pass too, per Battlewrath:
    #     "Crypt can be dropped also. It is only a channeled runic
    #     builder" - same builder classification as Lichfrost, just
    #     channeled instead of a windup cast. (The earlier "press_wash
    #     KEPT, no real cooldown" note below is now superseded by this -
    #     left in place as history, not deleted, since it's still accurate
    #     about why db.ascension.gg's 15s cooldown claim for this spell
    #     was wrong.)
    #   - COMMAND: UNDEAD (504868) - the only slot left. press_wash
    #     REMOVED from this build: it never reliably fired in-game for
    #     this ability even after the sourceUnit/spellName/CAST_SUCCESS
    #     fixes (see template_filler.py's press_wash comment) - shipping a
    #     feature that doesn't visibly work isn't "proving the UI."
    #     NOT deleted from the codebase - press_wash is confirmed
    #     genuinely working live (Lichfrost, real in-game test) and stays
    #     available as a fragment/schema/template_filler mechanism for
    #     whatever ability actually earns it next. Command: Undead keeps
    #     its afford-glow (power_threshold's include_afford_glow) - that
    #     one IS confirmed working and is the "opportunity" signal;
    #     press_wash was only ever the separate "response" signal layered
    #     on top, per Battlewrath's "Glow is opportunity. Wash is
    #     response" - dropping the response layer doesn't touch the
    #     opportunity layer underneath it.
    # ------------------------------------------------------------------
    "Tier 1 Rotation": {
        "region_type": "group",
        "slots": [
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
                    # press_wash intentionally omitted here (2026-07-06) -
                    # see this layer's own header comment above for why.
                },
            },
        ],
    },

    # ------------------------------------------------------------------
    # Layer 3: Necro_animation_spec_UI_element - Battlewrath's own live
    # dev/test group, indexed here 2026-07-08 so it's picked up in future
    # compiler builds/exports rather than only existing as a hand-edited
    # in-game aura. Reconstructed field-for-field from a real pasted
    # export (decoded via weakaura_codec.py) of the group Battlewrath is
    # actively using to prototype where this stuff lives on the mask -
    # positions here are Battlewrath's own current dev/test coordinates,
    # NOT a settled mask position (explicitly confirmed: "Undefined. This
    # will live around the UI for the necro" - a real mask is still being
    # worked out). Revisit x/y once that mask is settled.
    #
    # 3 slots:
    #   1. Life Force delta flash text (stack_delta_flash_text) - the
    #      already-formalized Life Force tracker, re-styled in-game:
    #      font 'MoK' (was 'Friz Quadrata TT'), font_size 13 (was 20),
    #      color recolored to a teal. The font override required adding
    #      a new 'font' param to stack_delta_flash_text this same pass
    #      (previously hardcoded, unreachable) - see build_templates.py's
    #      STACK_DELTA_FLASH_TEXT_SCHEMA for the field's own note.
    #   2. Undead Stance (stance_loader_icon) - same 3-option stance
    #      loader built 2026-07-08, moved into this dev group at
    #      Battlewrath's own chosen test position.
    #   3. Ward active (stance_loader_icon, NEW) - Battlewrath built this
    #      one THEMSELVES, by hand in-game, reusing the exact same
    #      stance_loader_icon mechanism (N name-matched aura2 triggers,
    #      disjunctive:any, activeTriggerMode:-10) for a second real
    #      mutually-exclusive pair: Fetid Ward vs Bone Ward. Bone Ward's
    #      own live trainer tooltip confirms "Only 1 Ward can be active
    #      at a time" (Outputs/live_reference/necromancer_live_reference.
    #      json) - the same mutual-exclusivity shape as the stances,
    #      independently confirmed. Indexed here as a real, compiler-
    #      tracked element (not just a hand-built one-off) per
    #      Battlewrath's explicit request: "I'd index it so it gets
    #      picked up in future builds for export."
    # ------------------------------------------------------------------
    "Necro_animation_spec_UI_element": {
        "region_type": "group",
        "slots": [
            {
                "template": "stack_delta_flash_text",
                "params": {
                    "name": "LF Delta Test",
                    "spell_id": 525004,
                    "aura_filter": "HARMFUL",
                    "x": 173.80164568420787,
                    "y": -109.3362841971246,
                    "label_suffix": " LF",
                    "font": "MoK",
                    "font_size": 13,
                    "color": [0.0, 0.6745098039215687, 0.5450980392156862, 1.0],
                },
            },
            {
                "template": "stance_loader_icon",
                "params": {
                    "name": "Undead Stance",
                    "option_names": ["Undead: Pacify", "Undead: Protect", "Undead: Assault"],
                    "x": 268.3431767418281,
                    "y": -109.29426707719983,
                },
            },
            {
                "template": "stance_loader_icon",
                "params": {
                    "name": "Ward active",
                    "option_names": ["Fetid Ward", "Bone Ward"],
                    "x": 309.12751436798817,
                    "y": -109.76470754778336,
                },
            },
        ],
    },
}
