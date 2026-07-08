"""
Bloodmage/inventory.py - this class's own slot data, per layer, for
layer_builder.py to consume. Plain constants only - see
Necromancer/inventory.py's own docstring / ../layer_builder.py's docstring
for the full architecture rationale (unchanged here, just a third class
consuming the same shared pipeline).

Resources tier filled in 2026-07-07 by the class-implementer pass (see
BUILD_METHOD.md and ../AGENT_ROLES.md). Required ordering was followed:
Bloodmage_fantasy_playstyle.md -> spell_index.md -> slot_assignment.md ->
this file's LAYERS content. Tier 1 Rotation added 2026-07-07 (800772).

Notes:
- Read ../AGENT_ROLES.md's "class implementer" role in full.
- The UnitHealth-driven top-50%-HP mechanic is a REAL, FORMALIZED
  capability as of 2026-07-09:
  rb.health_slot(name, min_percent, max_percent, position, bar_color=None)
  in Tiers/resources_base.py, backed by a real health_range_aurabar
  schema/template in Templates/build_templates.py. Called directly, same
  as rb.resource_slot() - see BUILD_METHOD.md's "FORMALIZED as a core
  capability" section for the full trail (Battlewrath: "It comes between
  us as a primitive capability first").
"""

import os
import sys

_THIS_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(_THIS_DIR, "..", "Tiers"))
import resources_base as rb

ACCENT_COLOR = [0.7765, 0.3804, 0.3804, 1.0]  # theme.json's accent_rgba (#c66161)

# Confirmed-present standard WoW PowerType for this class (see
# BUILD_METHOD.md's "Rage confirmed present (not Mana)" note) - Battlewrath
# corrected the initial Mana assumption directly ("the other energy is
# rage, not mana"), confirmed against bloodmage_skill_index.json's "Pooled
# Vitality"/"Unchained" entries ("Mortal Form spells that cost Rage...").
POWERTYPE_RAGE = rb.POWERTYPE_RAGE

# The "own life as a resource" mechanic (HP-as-resource, top-50%-of-health
# display) is a REAL, FORMALIZED capability now - rb.health_slot(...),
# backed by Templates/build_templates.py's health_range_aurabar (native
# Health unit trigger + the aurabar region's own adjustedMin/adjustedMax
# percent clamp, no Custom/stateupdate trigger needed). See
# BUILD_METHOD.md's "FORMALIZED as a core capability" section.

# Rage's bar color - FLAGGED, not a Bloodmage in-game capture. No real
# Bloodmage Rage bar has been captured, so its true barColor is unknown.
# resource_threshold_aurabar's own template default is Mana's captured BLUE,
# which is visibly wrong for a Rage bar; rather than ship blue OR invent a
# value, this is Blizzard's own canonical PowerBarColor["RAGE"]
# {0.77, 0.25, 0.25} - a real documented reference constant, not fabricated.
# Same "documented default, flag before assuming permanent" posture Reaper
# used for its Runic Power recolor. Replace if a real capture is taken. See
# spell_index.md's "Rage" entry for the full trail (incl. the note that it
# sits near the accent-red HP bar above it - coherent for a blood class,
# but confirm the two reds read as distinct in-game).
RAGE_BAR_COLOR = [0.77, 0.25, 0.25, 1.0]

# 800772 target-debuff glow color - a brighter/whiter red per Battlewrath's
# steer ("brighter/whiter red. Purple is for necro/reaper"). NOT the muted
# theme accent (#c66161) and NOT Murder's purple convention - a Bloodmage-
# flavored "offensive/debuff-presence tracker" color. First-pass value,
# tunable in-game (Battlewrath drives final color, we capture).
DEBUFF_GLOW_COLOR = [1.0, 0.4, 0.4, 1.0]  # ~#FF6666, bright light red

LAYERS = {
    # ------------------------------------------------------------------
    # Layer 1: Resources. Bloodmage's primary-resource slot
    # (CLASS_RESOURCE_POS, mask Row C "the class's core meter") holds
    # HEALTH, not Mana - this class has no Mana bar at all (like Reaper).
    # The health bar is clamped to the top 50%-100% of max HP via the
    # newly-formalized rb.health_slot() ("the life you can afford to
    # spend") - the exact capability that was formalized at the core layer
    # BEFORE this pass specifically so this class could consume it with no
    # escalation (BUILD_METHOD.md's "FORMALIZED as a core capability";
    # AGENT_ROLES.md lists it under "proven and safe to reuse"). Rage fills
    # the secondary-resource slot (CLASS_ENERGY_POS, mask Row D). Cast Bar /
    # Swing Timer / accent divider are the standard shared builders, same
    # as every prior class's Resources tier. Every slot here is an
    # already-proven rb.* builder - no new opportunity_type, no new
    # fragment, no bespoke Lua (per AGENT_ROLES.md's class-implementer
    # scope). Order mirrors Reaper: primary resource, secondary resource,
    # cast backing+bar, swing backing+bar, divider.
    # ------------------------------------------------------------------
    "Resources": {
        "region_type": "group",
        "slots": [
            rb.health_slot("HP Reserve", 50, 100, rb.CLASS_RESOURCE_POS, bar_color=ACCENT_COLOR),
            rb.resource_slot("Rage", POWERTYPE_RAGE, rb.CLASS_ENERGY_POS, bar_color=RAGE_BAR_COLOR),
            rb.cast_bar_backing_slot(),
            rb.cast_bar_slot(),
            rb.swing_timer_backing_slot(),
            rb.swing_timer_slot(),
            rb.divider_strip_slot(color=ACCENT_COLOR),
        ],
    },

    # ------------------------------------------------------------------
    # Layer 2: Tier 1 Rotation. First rotation-tier content for this class.
    # Positions from the mask (ELEMENT_INVENTORY.md Row B, "Tier 1 slot
    # Rotation" = the leftmost anchor at -107.5, -130, 40x30 icon - six
    # icon slots exist total across the row).
    #
    # 800772 (name TBC - Battlewrath's own given ID, validated in-game;
    # not in Outputs/skill_indices/bloodmage_skill_index.json, same as
    # Reaper's Murder IDs came from the live game, not the index) - a DoT
    # the player applies to the target, modeled EXACTLY on Reaper's Murder
    # (Templates/build_templates.py's glow_source opportunity_type
    # "target_debuff_presence"): a standard cooldown_tracker_icon for the
    # ability's ready/cooldown state, PLUS a glow_source entry that lights
    # the icon when the TARGET carries the player's own 800772 debuff
    # (aura2, unit:'target', ownOnly:true - a boolean presence "condition
    # checker," Battlewrath's framing for Murder, "not a DOT tracker in the
    # broad sense").
    #
    # SINGLE ID fills BOTH roles here (Battlewrath: "Same ID for both. I
    # already validated this in-game. The target aspect catches the ID
    # being seen twice") - the pressed ability's spell_id AND the applied
    # debuff's auraspellids are both 800772, so cooldown_tracker_icon's
    # spell_id and the glow_source entry's spell_id are the same number.
    #
    # FIRST pipeline build of target_debuff_presence: the capability was
    # FORMALIZED from Reaper's real, live-tested Murder capture but never
    # actually built through a class inventory.py before now (Reaper's is
    # the hand-built in-game version). Proven capability, not pipeline-
    # exercised until this - round-trip verified in slot_assignment.md.
    #
    # Glow color is a brighter/whiter red (DEBUFF_GLOW_COLOR), NOT Murder's
    # purple - Battlewrath: "Purple is for necro/reaper." Tunable in-game.
    # Minimal, Murder-matching build: no power_threshold / desaturate /
    # press_wash added (none were part of Murder's shape; add later only if
    # Battlewrath asks and the real cost/response data is confirmed).
    # ------------------------------------------------------------------
    "Tier 1 Rotation": {
        "region_type": "group",
        "slots": [
            {
                "template": "cooldown_tracker_icon",
                "params": {
                    "name": "Blood DoT (800772)",  # placeholder name - confirm real spell name
                    "spell_id": 800772,
                    "x": -107.5,
                    "y": -130,
                    "accent_color": ACCENT_COLOR,
                    "glow_source": [
                        {
                            "opportunity_type": "target_debuff_presence",
                            "spell_id": 800772,
                            "glow_color": DEBUFF_GLOW_COLOR,
                        },
                    ],
                },
            },
        ],
    },
}
