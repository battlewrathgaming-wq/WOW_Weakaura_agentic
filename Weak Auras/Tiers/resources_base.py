"""
Tiers/resources_base.py - shared, class-agnostic building blocks for the
Resources tier (ELEMENT_INVENTORY.md's Row C/D: Class resource / Cast bar /
Class energy / Swing Timer), plus the center-seam divider strip added
2026-07-09.

WHY THIS FILE EXISTS (settled with Battlewrath, 2026-07-09, right after
building the divider-strip fix for both Necromancer's Mana/Runic Power AND
Reaper's Soul Fragment/Runic Power in the same session): two classes
already need the exact same Runic Power bar, Cast Bar, Swing Timer, and
divider-strip mechanism - re-deriving or copy-pasting that per class would
drift the moment either copy got tweaked independently. Battlewrath's own
framing: "it's more centered on the mask / backing plates and positional
indexes as a source of truth per slot. Then a class defines with it's own
inventory how they're populated."

THREE-LAYER ARCHITECTURE this file is the middle layer of:
  1. THE MASK (ELEMENT_INVENTORY.md) - purely positional truth. Where a
     slot IS, in the abstract, independent of any class or content.
  2. THIS FILE - the generic "menu" of standard content that CAN occupy a
     given slot ROLE, fully specified (position, size, mechanism, real
     confirmed default colors) - a real, reusable building block, not a
     template needing re-derivation per class.
  3. A CLASS'S OWN inventory.py (e.g. Necromancer/inventory.py,
     Reaper/inventory.py) - picks which of this file's builders fill its
     own slots, applies any class-specific color override, and supplies
     whatever's genuinely bespoke for that class (e.g. Reaper's Soul
     Fragment, which has NO base entry here at all - it's not a standard
     WoW power type, so it stays wholly owned by Reaper/inventory.py).

GEOMETRY: matches Necromancer/Resources_v14_import.txt exactly (the
center-seam divider-strip redesign, live-confirmed-pending as of
2026-07-09 - see Necromancer/slot_assignment.md's own writeup for the full
derivation). Every bar is 126 wide (shrunk from the original 127.5),
stepped 0.75 further from center than before (left column -64.5, right
column 64.5) so each bar's OUTER edge is unchanged while a precise 3px gap
opens at the x=0 center seam for the divider strip to fill.

FIELD-FIDELITY NOTE: Cast Bar, Swing Timer, and both backing plates need
NO extra override params to reproduce Resources_v14_import.txt's real
captured fields exactly - confirmed by direct decode-vs-template-default
comparison (2026-07-09): player_cast_aurabar.template.json's barColor/
backgroundColor/subRegions already match Cast Bar's real captured shape
byte-for-byte (the historical color-sync/name-text passes already baked
these into the template's own defaults, not left as per-instance
overrides). Same for swing_timer_aurabar and backing_plate_aurabar. Only
Runic Power needs a bar_color override (cyan, #21E8FF) since Mana and
Runic Power share one template but were given different real colors.
"""

# ---------------------------------------------------------------------------
# Slot-role positions (post-2026-07-09 divider-strip geometry). Mirrors the
# mask - not re-derived per class, not invented here, just centralized.
# ---------------------------------------------------------------------------

CLASS_RESOURCE_POS = {"x": -64.5, "y": -152.5, "width": 126, "height": 15}
CLASS_ENERGY_POS = {"x": -64.5, "y": -167.5, "width": 126, "height": 15}
CAST_BAR_POS = {"x": 64.5, "y": -152.5, "width": 126, "height": 15}
SWING_TIMER_POS = {"x": 64.5, "y": -167.5, "width": 126, "height": 15}
DIVIDER_POS = {"x": 0, "y": -160, "width": 3, "height": 30}

# ---------------------------------------------------------------------------
# WoW's real PowerType enum - confirmed live 2026-07-06 for Mana=0 and Runic
# Power=6 (Necromancer's own Mana/Runic Power captures, decoded via
# weakaura_codec.py); the rest follow the same standard enum but are NOT yet
# independently confirmed live by this project - see
# resource_threshold_aurabar.schema.json's own "power_type" note, unchanged
# by this file.
#
# CONFIRMED 2026-07-09: Battlewrath's own list when proposing this file was
# "Mana, Rage, Runic power, Stamina, Combo points" - "Stamina" isn't a real
# WoW PowerType (it's a unit STAT, a wholly different API/UI element, not a
# resource_threshold_aurabar-style power bar), so this was flagged rather
# than silently substituted. Battlewrath confirmed Focus was actually meant.
# ---------------------------------------------------------------------------

POWERTYPE_MANA = 0
POWERTYPE_RAGE = 1
POWERTYPE_FOCUS = 2  # confirmed 2026-07-09 - this is what Battlewrath meant by "Stamina"
POWERTYPE_ENERGY = 3
POWERTYPE_COMBO_POINTS = 4
POWERTYPE_RUNES = 5
POWERTYPE_RUNIC_POWER = 6


def resource_slot(name, powertype, position, bar_color=None, threshold_value=None, end_cap_color=None):
    """Build a 'slots' entry for a standard resource_threshold_aurabar,
    anchored at one of this tier's mask-defined positions above (usually
    CLASS_RESOURCE_POS or CLASS_ENERGY_POS, but not enforced - a class may
    need a standard resource type somewhere non-standard).

    Deliberately does NOT default bar_color/end_cap_color here - omitting
    them keeps resource_threshold_aurabar's own template defaults (Mana's
    real captured blue, per that template's own baked-in default), same
    non-placeholder-risk pattern already established in template_filler.py.
    end_cap_color is NOT set by default post-2026-07-09 (the tick mechanism
    is superseded by the shared divider_strip_slot below) - only pass it if
    a class genuinely wants the old per-bar tick back for some reason.
    """
    params = {"name": name, "power_type": powertype, **position}
    if bar_color is not None:
        params["bar_color"] = list(bar_color)
    if threshold_value is not None:
        params["threshold_value"] = threshold_value
    if end_cap_color is not None:
        params["end_cap_color"] = list(end_cap_color)
    return {"template": "resource_threshold_aurabar", "params": params}


def health_slot(name, min_percent, max_percent, position, bar_color=None):
    """Build a 'slots' entry for a health_range_aurabar - a health bar
    clamped to a percent-of-max-health window (e.g. min_percent=50,
    max_percent=100 shows only the TOP HALF of HP - 'HP you can afford to
    lose/use', not total health remaining). Formalized 2026-07-09 as a
    primitive capability (Battlewrath: "I'd formalize the health side as a
    capability. Then the class agent can work from there... It comes
    between us as a primitive capability first" - not something a class's
    own inventory.py should invent locally, per AGENT_ROLES.md's escalation
    rule) after the mechanism was confirmed two ways: direct source read of
    Prototypes.lua's native 'Health' unit trigger + RegionPrototype.lua's
    adjustedMin/adjustedMax percent-suffix clamp, AND a real, live-tested
    WeakAuras export Battlewrath pasted and confirmed in-game (id
    'Bloodmage_hp_resouece_50-100%'). See health_range_aurabar's own
    schema/BUILD_METHOD.md's 'Escalation flag - RESOLVED' section for the
    full trail.

    min_percent/max_percent: PLAIN NUMBERS (e.g. 50, 100), NOT pre-suffixed
    strings - this function appends the required '%' itself. This is
    deliberate, not just convenience: Battlewrath's own real hand-built
    prototype set these fields to literal '50'/'100' with no '%' suffix,
    which WeakAuras reads as absolute hit-point values rather than
    percent-of-max (a real bug, caught by decoding that capture) - passing
    plain numbers through this builder makes that specific mistake
    structurally impossible for any class that uses it, rather than relying
    on each class remembering to type the '%' by hand.

    bar_color: optional RGBA override, same non-placeholder-risk pattern as
    resource_slot's own bar_color - omit to keep health_range_aurabar's own
    default (a neutral red, not tied to any one class's theme).
    """
    params = {
        "name": name,
        "min_percent": f"{min_percent}%",
        "max_percent": f"{max_percent}%",
        **position,
    }
    if bar_color is not None:
        params["bar_color"] = list(bar_color)
    return {"template": "health_range_aurabar", "params": params}


def cast_bar_backing_slot(name="Cast Bar Backing", position=None):
    position = position or CAST_BAR_POS
    return {"template": "backing_plate_aurabar", "params": {"name": name, **position}}


def cast_bar_slot(name="Cast Bar", position=None):
    """No color overrides needed - player_cast_aurabar's own template
    defaults already match the real captured Cast Bar exactly (confirmed
    2026-07-09 decode-vs-default comparison, see this file's own docstring)."""
    position = position or CAST_BAR_POS
    return {"template": "player_cast_aurabar", "params": {"name": name, **position}}


def swing_timer_backing_slot(name="Swing Timer Backing", position=None):
    position = position or SWING_TIMER_POS
    return {"template": "backing_plate_aurabar", "params": {"name": name, **position}}


def swing_timer_slot(name="Swing Timer", hand="main", position=None):
    """No color overrides needed - swing_timer_aurabar's own template
    defaults already match the real captured Swing Timer exactly (white
    barColor, confirmed 2026-07-09 decode-vs-default comparison)."""
    position = position or SWING_TIMER_POS
    return {"template": "swing_timer_aurabar", "params": {"name": name, "hand": hand, **position}}


def divider_strip_slot(name="Resources Divider", color=None, position=None):
    """The fixed, always-shown center-seam divider strip that replaced
    class_accent_tick_end for this tier (see Necromancer/slot_assignment.md's
    "end-cap tick replaced with a fixed center-seam divider strip" writeup
    for the full live-tested trail on why the tick mechanism was withdrawn -
    AtPercent tick placement depends on RegionPrototype.lua's
    GetMinMaxProgress, which zeroes out whenever the currently-active
    trigger lacks a real progressType/duration range - true for BOTH an
    aura2 'missing' state AND a plain always-true Unit Characteristics
    trigger, so no tick-based fix could have worked here regardless of
    which specific mechanism carried it).

    color default is the Necromancer accent (confirmed real value used in
    Resources_v14_import.txt) - NOT yet confirmed as a deliberate
    cross-class-constant choice vs. an inherited-by-default placeholder.
    Flag/ask before assuming Reaper's own instance should share this exact
    hex rather than using Reaper's own theme accent, if Reaper ever gets
    one.
    """
    position = position or DIVIDER_POS
    params = {"name": name, **position}
    params["background_color"] = list(color) if color is not None else [0.2706, 0.8588, 0.6118, 1.0]
    return {"template": "backing_plate_aurabar", "params": params}
