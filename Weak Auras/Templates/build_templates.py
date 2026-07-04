"""
Generates the phase-3 JSON Schema + template pairs for
WEAKAURA_INDEX.md's extended opportunity-type taxonomy (2026-07-04).

Every field name/default below is taken directly from this session's
phase-1 capability read (RegionTypes/Icon.lua, RegionTypes/AuraBar.lua,
SubRegionTypes/Glow.lua, SubRegionTypes/Border.lua, SubRegionTypes/Tick.lua,
SubRegionTypes/SubText.lua, Prototypes.lua's Cooldown Progress (Spell) and
Cast entries, BuffTrigger2.lua's aura2/showOnMissing) and from
weakaura_codec.py's own EXAMPLE_TEST_AURA (the real, live-validated envelope
shape - actions/animation/authorOptions/conditions/config/information/
internalVersion/load/triggers). Nothing here is invented field-naming;
where a field's exact runtime behavior (the "conditions" block driving
glow from a second trigger) hasn't been captured from a real live example,
that's flagged explicitly in the schema's own "verified" field rather than
presented as equally solid.
"""
import json
import os

_THIS_DIR = os.path.dirname(os.path.abspath(__file__))
SCHEMA_DIR = os.path.join(_THIS_DIR, "schemas")
TEMPLATE_DIR = os.path.join(_THIS_DIR, "templates")

# ---------------------------------------------------------------------------
# Shared fragments (referenced by $ref from multiple templates)
# ---------------------------------------------------------------------------

GLOW_SOURCE_SCHEMA = {
    "$id": "glow_source.schema.json",
    "title": "Glow-source fragment",
    "description": (
        "Not a standalone template - an OPTIONAL second trigger attachable "
        "to any icon-shaped template (cooldown_tracker today), per "
        "WEAKAURA_INDEX.md's 'glow-source mechanism' section. Represents "
        "HUD_DESIGN.md's settled rule: a proc/buff on an ability that "
        "already has its own Rotation button should brighten that button "
        "in place, not spawn a separate icon. Modeled as a LIST (settled "
        "2026-07-04: 'settling for 1 effect is fine... expanding is mostly "
        "just adding another of the same schema section') so a second "
        "independent proc later is additive, not a schema change."
    ),
    "type": "array",
    "maxItems_note": "1 today by settled scope; no hard cap enforced in the schema itself so extension stays additive.",
    "items": {
        "type": "object",
        "required": ["opportunity_type", "spell_id"],
        "properties": {
            "opportunity_type": {
                "type": "string",
                "enum": ["proc_alert", "buff_uptime"],
                "description": "Which of the two glow-eligible opportunity types this second spell is.",
            },
            "spell_id": {
                "type": ["string", "integer"],
                "description": "The proc/buff spell ID that should brighten the parent icon when active.",
            },
            "use_exact_spell_id": {"type": "boolean", "default": True},
        },
    },
    "verified": (
        "RESOLVED 2026-07-06 (was PARTIAL). The second numbered trigger "
        "slot (triggers[2]) was already confirmed real - EXAMPLE_TEST_AURA/"
        "EXAMPLE_GROUP_AURA show WeakAuras' triggers dict is keyed by "
        "integer trigger index, and Prototypes.lua/BuffTrigger2.lua confirm "
        "aura2/Cooldown trigger shapes independently. The remaining gap - "
        "the exact 'conditions' dict shape reading a genuinely SEPARATE "
        "trigger's state - is now closed by direct source read of "
        "Conditions.lua's CreateTestForCondition (the cType=='bool' branch "
        "generates state[trigger] and state[trigger].show and "
        "state[trigger][variable]==true, for whichever trigger number is "
        "given - not special-cased to trigger 1). See "
        "power_threshold_effect.schema.json for the sibling numeric-check "
        "version (cType=='number'), confirmed the same way."
    ),
}

STACK_COUNTER_OVERLAY_SCHEMA = {
    "$id": "stack_counter_overlay.schema.json",
    "title": "Stack-counter overlay fragment",
    "description": (
        "Not a standalone template - a subtext overlay layered on whichever "
        "trigger-bearing template (cooldown_tracker, buff_uptime, "
        "missing_buff, ...) already applies, per WEAKAURA_INDEX.md's "
        "stack_counter row: 'not a trigger of its own.'"
    ),
    "type": "object",
    "required": ["enabled"],
    "properties": {
        "enabled": {"type": "boolean"},
        "anchor_point": {"type": "string", "default": "BOTTOMRIGHT"},
        "font_size": {"type": "integer", "default": 12},
    },
    "verified": "Field names confirmed directly from SubRegionTypes/SubText.lua's default table.",
}

POWER_THRESHOLD_EFFECT_SCHEMA = {
    "$id": "power_threshold_effect.schema.json",
    "title": "Power-threshold effect fragment",
    "description": (
        "Not a standalone template - an OPTIONAL extra trigger (Power, unit "
        "player) attachable to any icon-shaped template, driving 'effects "
        "on the button' (never visibility - Battlewrath's explicit "
        "correction, 2026-07-06: rotation slots are fixed/always-visible, "
        "triggers only drive desaturate/glow/etc). Two effects, either or "
        "both: desaturate when the player can't afford the ability "
        "(always applied when this fragment is present), and an optional "
        "'afford glow' brightening the button's subglow once enough power "
        "is banked - the inverse comparison on the same trigger, no proc "
        "needed. Built from Necromancer's real Lichfrost/Crypt Swarm/"
        "Command: Undead (2026-07-06) - the first two cost a PERCENT of "
        "base mana, the third a FLAT Runic Power amount, hence "
        "cost_is_percent choosing between the Power trigger's 'percentpower' "
        "and 'power' state fields rather than assuming one shape."
    ),
    "type": "object",
    "required": ["powertype", "cost"],
    "properties": {
        "powertype": {
            "type": "integer",
            "description": "WeakAuras power type index (Mana = 0, Runic Power = 6 - confirmed Necromancer values, Necromancer/slot_assignment.md).",
        },
        "cost": {
            "type": "number",
            "description": "The ability's real cost - a percent (0-100) if cost_is_percent, otherwise a flat power amount.",
        },
        "cost_is_percent": {
            "type": "boolean",
            "default": False,
            "description": "True for a percent-of-base-mana cost (checks the Power trigger's 'percentpower' field); false for a flat amount (checks 'power').",
        },
        "include_afford_glow": {
            "type": "boolean",
            "default": False,
            "description": "If true, also glows the subglow subRegion once power >= cost (the inverse of the desaturate check) - e.g. Command: Undead's 'enough Runic Power banked' signal. Requires a subglow entry in the template's subRegions.",
        },
    },
    "verified": (
        "Trigger fields (power/total/percentpower/deficit/maxpower, all "
        "conditionType='number') confirmed directly from Prototypes.lua's "
        "['Power'] entry (line 2674). The generated condition code shape "
        "(cType=='number' branch) confirmed directly from Conditions.lua's "
        "CreateTestForCondition - not inferred by analogy, unlike "
        "glow_source's original caveat. Real cost data (Lichfrost/Crypt "
        "Swarm 10% base mana, Command: Undead 30 flat Runic Power) pulled "
        "from db.ascension.gg, 2026-07-06, cross-checked against the 30 RP "
        "figure already independently confirmed in slot_assignment.md."
    ),
}


# ---------------------------------------------------------------------------
# Base envelope - fields every leaf aura needs, identical for every template.
# Taken verbatim from weakaura_codec.py's EXAMPLE_TEST_AURA (the real,
# live-validated shape), minus the fields each template specializes.
# ---------------------------------------------------------------------------

def base_envelope():
    return {
        "actions": {"finish": {}, "init": {}, "start": {}},
        "alpha": 1,
        "anchorFrameType": "SCREEN",
        "anchorPoint": "CENTER",
        "animation": {
            "finish": {"duration_type": "seconds", "easeStrength": 3, "easeType": "none", "type": "none"},
            "main": {"duration_type": "seconds", "easeStrength": 3, "easeType": "none", "type": "none"},
            "start": {"duration_type": "seconds", "easeStrength": 3, "easeType": "none", "type": "none"},
        },
        "authorOptions": {},
        "conditions": {},
        "config": {},
        "frameStrata": 1,
        "information": {},
        "internalVersion": 86,
        "load": {"class": {"multi": {}}, "size": {"multi": {}}, "spec": {"multi": {}}},
        "selfPoint": "CENTER",
        "xOffset": "{{x}}",
        "yOffset": "{{y}}",
        "id": "{{name}}",
        "uid": "{{uid}}",
    }

# ---------------------------------------------------------------------------
# 1. cooldown_tracker (icon) - Rotation / Power-button tiers
# ---------------------------------------------------------------------------

COOLDOWN_TRACKER_ICON_SCHEMA = {
    "$id": "cooldown_tracker_icon.schema.json",
    "opportunity_type": "cooldown_tracker",
    "title": "Cooldown tracker (icon)",
    "description": "A first-class ability with a real cooldown - Rotation or Power-button tier icon.",
    "region_type": "icon",
    "trigger": "Cooldown Progress (Spell)",
    "type": "object",
    "required": ["name", "spell_id", "x", "y"],
    "properties": {
        "name": {"type": "string", "description": "Aura id/label."},
        "spell_id": {"type": ["string", "integer"]},
        "x": {"type": "number"},
        "y": {"type": "number"},
        "width": {"type": "number", "default": 40},
        "height": {"type": "number", "default": 30},
        "accent_color": {
            "type": "array",
            "default": [1, 1, 1, 1],
            "description": "subborder's color - class accent (theme.json's accent_rgba) recommended for the design language's consistent border language; defaults to Border.lua's own real white default if omitted.",
        },
        "glow_source": {"$ref": "glow_source.schema.json", "description": "Optional - see glow-source fragment."},
        "stack_counter": {"$ref": "stack_counter_overlay.schema.json"},
        "power_threshold": {
            "$ref": "power_threshold_effect.schema.json",
            "description": "Optional - see power-threshold-effect fragment. Desaturate-on-insufficient-power and/or afford-glow, never visibility.",
        },
    },
    "verified": (
        "Icon default fields from RegionTypes/Icon.lua; trigger fields from "
        "Prototypes.lua's 'Cooldown Progress (Spell)' entry (line 3742). "
        "Field shape confirmed live-tested in Template_shadow.py's own "
        "Rotation/Power-button icons (regionType=icon, cooldown=true). "
        "Extended 2026-07-06 with a subborder (icon-variant fields "
        "live-confirmed via the real Test_Board_validation export) and the "
        "optional power_threshold fragment, promoting ROTATION_ICON_PATTERN.md "
        "from a documented-but-unwired design into an actual reusable "
        "capability - first real consumers: Necromancer's Lichfrost/Crypt "
        "Swarm/Command: Undead."
    ),
}

COOLDOWN_TRACKER_ICON_TEMPLATE = {
    "regionType": "icon",
    "width": "{{width}}",
    "height": "{{height}}",
    "color": [1, 1, 1, 1],
    "desaturate": False,
    "iconSource": -1,
    "displayIcon": "",
    "cooldown": True,
    "cooldownEdge": False,
    "inverse": False,
    "zoom": 0,
    "keepAspectRatio": False,
    "progressSource": [-1, ""],
    "adjustedMax": "",
    "adjustedMin": "",
    "useAdjustededMax": False,
    "useAdjustededMin": False,
    "subRegions": [
        {"type": "subbackground"},
        {
            # Icon-variant fields only (no anchor_area - live-confirmed
            # 2026-07-06 via the real Test_Board_validation export; Border.lua
            # only adds anchor_area for aurabar parents). border_color carries
            # {{accent_color}} - defaults to Border.lua's own real white
            # default ([1,1,1,1]) if the caller doesn't override it, same
            # setdefault-from-schema-default pattern width/height already use.
            "type": "subborder",
            "border_size": 2,
            "border_color": "{{accent_color}}",
            "border_visible": True,
            "border_edge": "Square Full White",
            "border_offset": 0,
        },
        {
            "type": "subglow",
            "glow": False,
            "glowType": "buttonOverlay",
            "useGlowColor": False,
            "glowColor": [1, 1, 1, 1],
            "glowLines": 8,
            "glowFrequency": 0.25,
            "glowDuration": 1,
            "glowLength": 10,
            "glowThickness": 1,
            "glowScale": 1,
            "glowBorder": False,
            "glowXOffset": 0,
            "glowYOffset": 0,
        },
    ],
    "triggers": {
        "1": {
            "trigger": {
                "type": "spell",
                "event": "Cooldown Progress (Spell)",
                "spellName": "{{spell_id}}",
                "use_exact_spellName": True,
                "genericShowOn": "showAlways",
            },
            "untrigger": {},
        },
        "activeTriggerMode": -10,
    },
}


# ---------------------------------------------------------------------------
# 2. proc_alert (icon, standalone) - Proc/Condition tier
# ---------------------------------------------------------------------------

PROC_ALERT_ICON_SCHEMA = {
    "$id": "proc_alert_icon.schema.json",
    "opportunity_type": "proc_alert",
    "title": "Proc alert (icon, standalone)",
    "description": (
        "A second-order (talent/passive) ability with ProcChance < 100, "
        "used as its OWN icon. Per HUD_DESIGN.md, only use this template "
        "when the procced ability has no existing Rotation button to "
        "react in place - otherwise use this same opportunity type as a "
        "glow_source on a cooldown_tracker_icon instead."
    ),
    "region_type": "icon",
    "trigger": "Combat Log (Spell Cast Success / Aura Applied)",
    "type": "object",
    "required": ["name", "spell_id", "x", "y"],
    "properties": {
        "name": {"type": "string"},
        "spell_id": {"type": ["string", "integer"]},
        "x": {"type": "number"},
        "y": {"type": "number"},
        "width": {"type": "number", "default": 40},
        "height": {"type": "number", "default": 20},
    },
    "verified": "Trigger category confirmed in Prototypes.lua ('Combat Log', line 3157); the specific Spell Cast Success/Aura Applied sub-filter matches WEAKAURA_INDEX.md's existing proc_alert row, not independently re-verified field-by-field this pass.",
}

PROC_ALERT_ICON_TEMPLATE = {
    "regionType": "icon",
    "width": "{{width}}",
    "height": "{{height}}",
    "color": [1, 1, 1, 1],
    "desaturate": False,
    "iconSource": -1,
    "displayIcon": "",
    "cooldown": False,
    "cooldownEdge": False,
    "inverse": False,
    "zoom": 0,
    "keepAspectRatio": False,
    "progressSource": [-1, ""],
    "adjustedMax": "",
    "adjustedMin": "",
    "useAdjustededMax": False,
    "useAdjustededMin": False,
    "subRegions": [{"type": "subbackground"}],
    "triggers": {
        "1": {
            "trigger": {
                "type": "combatlog",
                "event": "Combat Log",
                "subeventPrefix": "SPELL",
                "subeventSuffix": "_CAST_SUCCESS",
                "spellIds": ["{{spell_id}}"],
                "use_spellId": True,
            },
            "untrigger": {},
        },
        "activeTriggerMode": -10,
    },
}

# ---------------------------------------------------------------------------
# 3a. buff_uptime (icon, permanent on/off) - Buffs/Utility footer
# ---------------------------------------------------------------------------

BUFF_UPTIME_ICON_SCHEMA = {
    "$id": "buff_uptime_icon.schema.json",
    "opportunity_type": "buff_uptime",
    "title": "Buff uptime (icon, permanent on/off)",
    "description": "A buff/debuff with durationMs negative ('Until cancelled') - a toggle state, not a timer.",
    "region_type": "icon",
    "trigger": "Aura",
    "type": "object",
    "required": ["name", "spell_id", "x", "y"],
    "properties": {
        "name": {"type": "string"},
        "spell_id": {"type": ["string", "integer"]},
        "x": {"type": "number"},
        "y": {"type": "number"},
        "width": {"type": "number", "default": 30},
        "height": {"type": "number", "default": 20},
        "own_only": {"type": "boolean", "default": True},
    },
    "verified": "Trigger type 'aura2' confirmed live-tested (Buffs/Utility static slots in Template_shadow.py). BuffTrigger2.lua registers 'aura2' (line 3798).",
}

BUFF_UPTIME_ICON_TEMPLATE = {
    "regionType": "icon",
    "width": "{{width}}",
    "height": "{{height}}",
    "color": [1, 1, 1, 1],
    "desaturate": False,
    "iconSource": -1,
    "displayIcon": "",
    "cooldown": False,
    "cooldownEdge": False,
    "inverse": False,
    "zoom": 0,
    "keepAspectRatio": False,
    "progressSource": [-1, ""],
    "adjustedMax": "",
    "adjustedMin": "",
    "useAdjustededMax": False,
    "useAdjustededMin": False,
    "subRegions": [{"type": "subbackground"}],
    "triggers": {
        "1": {
            "trigger": {
                "type": "aura2",
                "event": "Health",
                "unit": "player",
                "debuffType": "HELPFUL",
                "spellIds": ["{{spell_id}}"],
                "useExactSpellId": True,
                "ownOnly": "{{own_only}}",
                "names": [],
                "subeventPrefix": "SPELL",
                "subeventSuffix": "_CAST_START",
            },
            "untrigger": {},
        },
        "activeTriggerMode": -10,
    },
}

# ---------------------------------------------------------------------------
# 3b. buff_uptime (aurabar, countdown) - Buffs/Utility or Resources
# ---------------------------------------------------------------------------

BUFF_UPTIME_AURABAR_SCHEMA = {
    "$id": "buff_uptime_aurabar.schema.json",
    "opportunity_type": "buff_uptime",
    "title": "Buff uptime (aurabar, countdown)",
    "description": "A buff/debuff with a positive, finite durationMs - a countdown bar rather than a toggle icon.",
    "region_type": "aurabar",
    "trigger": "Aura",
    "type": "object",
    "required": ["name", "spell_id", "x", "y"],
    "properties": {
        "name": {"type": "string"},
        "spell_id": {"type": ["string", "integer"]},
        "x": {"type": "number"},
        "y": {"type": "number"},
        "width": {"type": "number", "default": 127.5},
        "height": {"type": "number", "default": 15},
    },
    "verified": "aurabar default fields from RegionTypes/AuraBar.lua; aura2 trigger shape shared with buff_uptime_icon above.",
}

BUFF_UPTIME_AURABAR_TEMPLATE = {
    "regionType": "aurabar",
    "width": "{{width}}",
    "height": "{{height}}",
    "orientation": "HORIZONTAL",
    "inverse": False,
    "barColor": [1.0, 0.0, 0.0, 1.0],
    "barColor2": [1.0, 1.0, 0.0, 1.0],
    "enableGradient": False,
    "gradientOrientation": "HORIZONTAL",
    "backgroundColor": [0.0, 0.0, 0.0, 0.5],
    "texture": "Blizzard",
    "textureSource": "LSM",
    "icon": False,
    "icon_side": "RIGHT",
    "icon_color": [1.0, 1.0, 1.0, 1.0],
    "desaturate": False,
    "iconSource": -1,
    "displayIcon": "",
    "zoom": 0,
    "progressSource": [-1, ""],
    "adjustedMax": "",
    "adjustedMin": "",
    "useAdjustededMax": False,
    "useAdjustededMin": False,
    "spark": False,
    "sparkWidth": 10, "sparkHeight": 30, "sparkColor": [1.0, 1.0, 1.0, 1.0],
    "sparkTexture": "Interface\\CastingBar\\UI-CastingBar-Spark",
    "sparkBlendMode": "ADD", "sparkOffsetX": 0, "sparkOffsetY": 0,
    "sparkRotationMode": "AUTO", "sparkRotation": 0, "sparkHidden": "NEVER",
    "subRegions": [{"type": "subbackground"}],
    "triggers": {
        "1": {
            "trigger": {
                "type": "aura2",
                "event": "Health",
                "unit": "player",
                "debuffType": "HELPFUL",
                "spellIds": ["{{spell_id}}"],
                "useExactSpellId": True,
                "ownOnly": True,
                "names": [],
                "subeventPrefix": "SPELL",
                "subeventSuffix": "_CAST_START",
            },
            "untrigger": {},
        },
        "activeTriggerMode": -10,
    },
}

# ---------------------------------------------------------------------------
# 4. resource_threshold (aurabar + subtick) - Resources tier
# ---------------------------------------------------------------------------

RESOURCE_THRESHOLD_AURABAR_SCHEMA = {
    "$id": "resource_threshold_aurabar.schema.json",
    "opportunity_type": "resource_threshold",
    "title": "Resource threshold (aurabar + tick marker)",
    "description": "A unit-resource bar (mana/rage/energy/runic power/etc.) with a marker at a fixed threshold value - not spell-based.",
    "region_type": "aurabar",
    "trigger": "Power",
    "type": "object",
    "required": ["name", "power_type", "x", "y"],
    "properties": {
        "name": {"type": "string"},
        "power_type": {
            "type": "integer",
            "description": "CORRECTED 2026-07-06 against a real live capture (Necromancer's own 'Mana'/'Runic power' auras, decoded via weakaura_codec.py) - this was originally documented as a string enum name (e.g. 'MANA', 'RUNIC_POWER'), which was wrong. WeakAuras' real Power trigger field is 'powertype' (no underscore) and its value is the RAW NUMERIC WoW PowerType enum, not a string. Confirmed live: 0 = Mana, 6 = Runic Power (the same enum value Death Knights use - direct confirmation of the 'DK's version, re-used' hypothesis, not just corroborated by a display name). Other values not yet individually confirmed live, but follow the same standard WoW enum: 1 = Rage, 2 = Focus, 3 = Energy, 4 = Combo Points, 5 = Runes.",
        },
        "threshold_value": {
            "type": "number",
            "description": "OPTIONAL, fixed 2026-07-06 (later same day) - the value the subtick marker is placed at (e.g. 80 for '80 Runic Power'). Previously this was baked into the static template unconditionally as a '{{threshold_value}}' placeholder, which was NEVER substituted for Mana/Runic Power (neither was ever given a threshold) and shipped as a literal, broken string in both real built auras - caught while adding the value-readout subtext below. Fixed: template_filler.py now only appends a subtick subRegion when this param is actually supplied, same pattern as stack_counter/glow_source. Omit entirely for a plain bar with no threshold marker.",
        },
        "bar_color": {
            "type": "array",
            "description": "OPTIONAL, added 2026-07-06 (fourth revision) - RGBA override for barColor, e.g. [0.129, 0.910, 1, 1]. Needed because Mana and Runic Power share this one template but Battlewrath gave them different in-game colors (Runic Power recolored to a cyan, #21E8FF; Mana left at the template's own default blue). Applied as a direct fill-time override (template_filler.py), same non-placeholder pattern as threshold_value, so omitting it just keeps the template's default barColor - no unresolved-placeholder risk.",
        },
        "end_cap_color": {
            "type": "array",
            "description": "OPTIONAL, added 2026-07-06 (tenth pass) - RGBA color for a PERMANENT end-cap marker at the bar's own 100% position, distinct from threshold_value's subtick. Problem this solves: once the backing plate's darkness was matched to the real bars (ninth pass), Mana/Runic Power visually fused with their adjacent Cast Bar/Swing Timer backing plate into one continuous strip, erasing the seam that used to mark where the resource bar's own max extent was - so at rest (not casting), a 50%-full bar had no reference point to gauge fill against. Backed by the shared 'class_accent_tick_end' FRAGMENT (see FRAGMENTS/FRAGMENT_TEMPLATES below) - a named, reusable design-language element intended for any aurabar across any class's UI, not just this one. Uses tick_placement_mode='AtPercent' (not 'AtValue', which threshold_value uses) - confirmed in Tick.lua's UpdateTickPlacementOne: AtPercent resolves 'minValue + placements[i]*valueRange/100' against GetMinMaxProgress() at render time, so placements=['100'] always lands at the CURRENT true max (whatever max mana/RP actually is at the player's level/gear) - no hardcoded number needed, unlike AtValue. CORRECTED 2026-07-06 (eleventh pass) after a real live-test bug: the first version of this fragment (and threshold_value's, sharing the same defect) omitted 3 fields present in Tick.lua's own default() table - progressSources, automatic_length, tick_texture - and stored tick_placements as a JSON number instead of the string WeakAuras itself uses. Battlewrath reported the in-game tick_placements read '50' (Tick.lua's own stock default) until manually re-entered as 100; decoding Battlewrath's real re-exported aura confirmed the missing-fields/string-type gap exactly. Fixed by matching Tick.lua's default() shape completely.",
        },
        "x": {"type": "number"},
        "y": {"type": "number"},
        "width": {"type": "number", "default": 127.5},
        "height": {"type": "number", "default": 15},
    },
    "verified": "aurabar fields as above. subtick fields from SubRegionTypes/Tick.lua's default table (tick_placement_mode='AtValue'). Power trigger category confirmed in Prototypes.lua (line 2674). UPGRADED 2026-07-06 from name-only to fully live-verified: decoded two real Necromancer captures ('Mana', 'Runic power' - both plain WeakAuras-native Progress Bar quick-auras, 200x30, unpositioned) via weakaura_codec.py. Confirmed real trigger shape: {type: 'unit', event: 'Power', unit: 'player', use_powertype: true, powertype: <int>} - matches this template exactly except power_type's type (see its own field description). The trigger dict also carries several inert leftover fields (debuffType, names, spellIds, subeventPrefix/Suffix, use_absorbMode, use_showAbsorb, use_showIncomingHeal) that don't apply to a Power-event trigger - harmless WeakAuras UI defaults from its aggregate trigger-config table, not something this template needs to reproduce. VALUE READOUT (added 2026-07-06, later same day, per Battlewrath: 'have the resource bars on the left most side show a static read out of their current value'): a subtext, text '%p', anchored INNER_LEFT. Power trigger has progressType='static' (Prototypes.lua line 2676) with state.value/state.total set from 'power'/'total' (current/max) locals (lines 2866-2891) - Private.dynamic_texts['p'] (WeakAuras.lua) returns state.value UNFORMATTED whenever progressType isn't 'timed', so '%p' resolves to the plain current power number here, exactly the readout asked for (not a percentage or a countdown - those only apply on the Cast/Swing Timer triggers' progressType='timed' path). END-CAP MARKER (added 2026-07-06, tenth/eleventh pass, discussed with Battlewrath before building per CLAUDE.md's working agreement): see end_cap_color property description above and the class_accent_tick_end FRAGMENT's own verified note for the full technical trail, including the real live-tested field-parity bug and its fix.",
}

RESOURCE_THRESHOLD_AURABAR_TEMPLATE = {
    "regionType": "aurabar",
    "width": "{{width}}",
    "height": "{{height}}",
    "orientation": "HORIZONTAL",
    "inverse": False,
    "barColor": [0.0, 0.4, 1.0, 1.0],
    "backgroundColor": [0.0, 0.0, 0.0, 0.5],
    "texture": "Blizzard",
    "textureSource": "LSM",
    "icon": False,
    "desaturate": False,
    "iconSource": -1,
    "displayIcon": "",
    "zoom": 0,
    "progressSource": [-1, ""],
    "adjustedMax": "", "adjustedMin": "",
    "useAdjustededMax": False, "useAdjustededMin": False,
    "spark": False,
    "subRegions": [
        {"type": "subbackground"},
        {
            "type": "subtext",
            "text_text": "%p",
            "text_color": [1, 1, 1, 1],
            "text_font": "Friz Quadrata TT",
            "text_fontSize": 12,
            "text_fontType": "None",
            "text_justify": "CENTER",
            "text_visible": True,
            "text_selfPoint": "AUTO",
            "anchor_point": "INNER_LEFT",
            "anchorXOffset": 0,
            "anchorYOffset": 0,
            "text_shadowColor": [0, 0, 0, 1],
            "text_shadowXOffset": 1,
            "text_shadowYOffset": -1,
        },
    ],
    "triggers": {
        "1": {
            "trigger": {
                "type": "unit",
                "event": "Power",
                "unit": "player",
                "use_powertype": True,
                "powertype": "{{power_type}}",
            },
            "untrigger": {},
        },
        "activeTriggerMode": -10,
    },
}

# ---------------------------------------------------------------------------
# 5. missing_buff (icon, showOnMissing) - Buffs/Utility dynamic slots
# ---------------------------------------------------------------------------

MISSING_BUFF_ICON_SCHEMA = {
    "$id": "missing_buff_icon.schema.json",
    "opportunity_type": "missing_buff",
    "title": "Missing buff (icon, showOnMissing)",
    "description": "Shows only when a named personal buff is ABSENT - the Buffs/Utility dynamic-overflow mechanism.",
    "region_type": "icon",
    "trigger": "Aura (matchesShowOn = showOnMissing)",
    "type": "object",
    "required": ["name", "spell_id", "x", "y"],
    "properties": {
        "name": {"type": "string"},
        "spell_id": {"type": ["string", "integer"]},
        "x": {"type": "number"},
        "y": {"type": "number"},
        "width": {"type": "number", "default": 30},
        "height": {"type": "number", "default": 20},
    },
    "verified": "Confirmed by direct source read: BuffTrigger2.lua has a real matchesShowOn == 'showOnMissing' mode. Already load-bearing in Template_shadow.py's design (v0.13+ reserves the positional slots), though the actual trigger dict for showOnMissing specifically has not yet been captured from a real live-tested example in this project - same caveat as the glow_source conditions block.",
}

MISSING_BUFF_ICON_TEMPLATE = {
    "regionType": "icon",
    "width": "{{width}}",
    "height": "{{height}}",
    "color": [1, 1, 1, 1],
    "desaturate": False,
    "iconSource": -1,
    "displayIcon": "",
    "cooldown": False,
    "cooldownEdge": False,
    "inverse": False,
    "zoom": 0,
    "keepAspectRatio": False,
    "progressSource": [-1, ""],
    "adjustedMax": "", "adjustedMin": "",
    "useAdjustededMax": False, "useAdjustededMin": False,
    "subRegions": [{"type": "subbackground"}],
    "triggers": {
        "1": {
            "trigger": {
                "type": "aura2",
                "event": "Health",
                "unit": "player",
                "debuffType": "HELPFUL",
                "spellIds": ["{{spell_id}}"],
                "useExactSpellId": True,
                "ownOnly": True,
                "matchesShowOn": "showOnMissing",
                "names": [],
                "subeventPrefix": "SPELL",
                "subeventSuffix": "_CAST_START",
            },
            "untrigger": {},
        },
        "activeTriggerMode": -10,
    },
}


# ---------------------------------------------------------------------------
# 6. enemy_cast (aurabar) - future DynamicGroup module, outside the 5 tiers
# ---------------------------------------------------------------------------

ENEMY_CAST_AURABAR_SCHEMA = {
    "$id": "enemy_cast_aurabar.schema.json",
    "opportunity_type": "enemy_cast",
    "title": "Enemy/target cast bar",
    "description": (
        "unit=target/focus Cast trigger. Deliberately OUTSIDE HUD_DESIGN.md's "
        "five fixed tiers - variable-count (0-N enemies), planned as a "
        "separate DynamicGroup module, not a fixed HUD slot. This template "
        "is a structural stub for that future module, not wired into "
        "Template_shadow.py."
    ),
    "region_type": "aurabar",
    "trigger": "Cast",
    "type": "object",
    "required": ["name", "unit", "x", "y"],
    "properties": {
        "name": {"type": "string"},
        "unit": {"type": "string", "enum": ["target", "focus"], "default": "target"},
        "spell_id_filter": {"type": ["string", "integer", "null"], "description": "Optional - restrict to specific dangerous casts; null shows any cast."},
        "x": {"type": "number"},
        "y": {"type": "number"},
        "width": {"type": "number", "default": 127.5},
        "height": {"type": "number", "default": 15},
    },
    "verified": "Cast trigger with unit=target/focus confirmed directly in Prototypes.lua (line 7010) and Types.lua's actual_unit_types_cast. NOT built or live-tested - structural only, per WEAKAURA_INDEX.md's status for this row.",
}

ENEMY_CAST_AURABAR_TEMPLATE = {
    "regionType": "aurabar",
    "width": "{{width}}",
    "height": "{{height}}",
    "orientation": "HORIZONTAL",
    "inverse": False,
    "barColor": [1.0, 0.2, 0.2, 1.0],
    "backgroundColor": [0.0, 0.0, 0.0, 0.5],
    "texture": "Blizzard",
    "textureSource": "LSM",
    "icon": True,
    "icon_side": "LEFT",
    "icon_color": [1.0, 1.0, 1.0, 1.0],
    "desaturate": False,
    "iconSource": -1,
    "displayIcon": "",
    "zoom": 0,
    "progressSource": [-1, ""],
    "adjustedMax": "", "adjustedMin": "",
    "useAdjustededMax": False, "useAdjustededMin": False,
    "spark": True,
    "sparkWidth": 4, "sparkHeight": 20, "sparkColor": [1.0, 1.0, 1.0, 1.0],
    "sparkTexture": "Interface\\CastingBar\\UI-CastingBar-Spark",
    "sparkBlendMode": "ADD", "sparkOffsetX": 0, "sparkOffsetY": 0,
    "sparkRotationMode": "AUTO", "sparkRotation": 0, "sparkHidden": "NEVER",
    "subRegions": [{"type": "subbackground"}],
    "triggers": {
        "1": {
            "trigger": {
                "type": "unit",
                "event": "Cast",
                "unit": "{{unit}}",
                "use_spellName": "{{use_spell_id_filter}}",
                "spellName": "{{spell_id_filter}}",
            },
            "untrigger": {},
        },
        "activeTriggerMode": -10,
    },
}

# ---------------------------------------------------------------------------
# 6b. player_cast (aurabar) - Resources tier (settled 2026-07-06)
# ---------------------------------------------------------------------------

PLAYER_CAST_AURABAR_SCHEMA = {
    "$id": "player_cast_aurabar.schema.json",
    "opportunity_type": "player_cast",
    "title": "Player cast bar",
    "description": (
        "The player's OWN cast-time progress - joins the Resources tier "
        "(HUD_DESIGN.md, settled 2026-07-06), alongside Health/Mana, per "
        "Luxthos Mage's real convention (a dedicated Cast Bar living in the "
        "same Resources section, same aurabar style/size as Health/Mana - "
        "not Fojji's separate dedicated-section convention). Distinct from "
        "enemy_cast_aurabar (unit=target/focus, deliberately outside the "
        "five tiers) - this one is unit=player, fixed-address, inside "
        "Resources, matching ELEMENT_INVENTORY.md's 'Cast bar' slot "
        "(Row C). REVISED 2026-07-06 (later same day, Battlewrath's direct "
        "request): has an 'always-shown shadow footprint' now, not just a "
        "trigger-gated bar that vanishes when not casting - see the "
        "'idle-shadow mechanism' note below."
    ),
    "region_type": "aurabar",
    "trigger": "Cast",
    "type": "object",
    "required": ["name", "x", "y"],
    "properties": {
        "name": {"type": "string"},
        "x": {"type": "number"},
        "y": {"type": "number"},
        "width": {"type": "number", "default": 127.5},
        "height": {"type": "number", "default": 15},
    },
    "verified": (
        "Cast trigger with unit=player confirmed directly in Prototypes.lua "
        "(line ~7010, progressType='timed' at line 7053) - the same trigger "
        "category enemy_cast_aurabar already verified, just a fixed unit "
        "instead of a variable one. aurabar default fields shared with "
        "buff_uptime_aurabar/resource_threshold_aurabar (RegionTypes/"
        "AuraBar.lua). "
        "IDLE-SHADOW MECHANISM - ATTEMPTED THEN WITHDRAWN (2026-07-06). A "
        "second 'Unit Characteristics' trigger + activeTriggerMode=-10 + a "
        "trigger-1-show alpha Condition was built to keep this bar always "
        "visible (dim when idle, bright when casting). Live-tested by "
        "Battlewrath: it did NOT work as designed - the bar was actually "
        "present before ever being triggered, but then HID once the real "
        "Cast trigger fired (backwards from intent). Rather than debug "
        "WeakAuras' multi-trigger 'first_active' combination logic further, "
        "Battlewrath's call: 'I think the backing entity is the fix here "
        "rather than over complicate the auras.' WITHDRAWN accordingly - "
        "this template is back to a single trigger, full alpha always, "
        "normal show/hide behavior. The persistent-footprint job now "
        "belongs entirely to the separate backing_plate_aurabar element "
        "(see that schema) positioned underneath at the same address. "
        "Timer text kept: a '%p' subtext anchored INNER_RIGHT (matches "
        "SubText.lua's own addDefaultsForNewAura default position for an "
        "aurabar's right-side subtext, just swapping its default '%n' text "
        "for '%p' per Battlewrath's ask for 'a timer on the right side, "
        "static' - '%p' resolves via Private.dynamic_texts['p'] to "
        "remaining time whenever state.progressType=='timed'). COLOR "
        "SYNCED 2026-07-06: barColor/backgroundColor match Battlewrath's "
        "real in-game recolor of Cast Bar (#9ED9FF barColor, backgroundColor "
        "alpha 0.73, decoded from a real pasted export of the actually-"
        "imported v1 aura). "
        "ICON: BRIEFLY REMOVED, THEN RESTORED WITH CORRECTED UNDERSTANDING "
        "(2026-07-06). First pass wrongly diagnosed 'icon:true' as the "
        "cause of a reported spacing gap and disabled it. Battlewrath "
        "corrected this: 'They consume the space outlined by the bar "
        "total' - confirmed directly in RegionTypes/AuraBar.lua's "
        "HORIZONTAL width function ('return self.totalWidth - self."
        "iconWidth, self.totalHeight') - the icon slot is carved OUT OF "
        "the bar's own configured width/height (127.5x15, unchanged), not "
        "added as overflow beyond it. So icon:true costs no extra "
        "footprint at all once width/height are already set correctly, "
        "which they were. Restored to icon:true. Also confirmed why it's "
        "wanted: per Battlewrath, 'the work they do is feedback, as they "
        "use the icon of what triggered them' - with iconSource=-1 "
        "(already set here), AuraBar.lua's UpdateIcon() reads iconPath "
        "from self.state.icon directly (RegionTypes/AuraBar.lua line "
        "1025-1039). The Cast trigger's own 'icon' state field (Prototypes."
        "lua line ~7190, init='icon', fed by UnitCastingInfo/"
        "UnitChannelInfo's icon return value) is the SPELL's icon - so "
        "this bar automatically shows which spell is being cast, no extra "
        "config needed. Not yet rebuilt/live-tested since this correction."
    ),
}

PLAYER_CAST_AURABAR_TEMPLATE = {
    "regionType": "aurabar",
    "width": "{{width}}",
    "height": "{{height}}",
    "orientation": "HORIZONTAL",
    "inverse": False,
    "alpha": 1,
    "barColor": [0.6196078431372549, 0.8509803921568627, 1, 1],
    "backgroundColor": [0.0, 0.0, 0.0, 0.73],
    "texture": "Blizzard",
    "textureSource": "LSM",
    "icon": True,
    "icon_side": "LEFT",
    "icon_color": [1.0, 1.0, 1.0, 1.0],
    "desaturate": False,
    "iconSource": -1,
    "displayIcon": "",
    "zoom": 0,
    "progressSource": [-1, ""],
    "adjustedMax": "", "adjustedMin": "",
    "useAdjustededMax": False, "useAdjustededMin": False,
    "spark": True,
    "sparkWidth": 4, "sparkHeight": 20, "sparkColor": [1.0, 1.0, 1.0, 1.0],
    "sparkTexture": "Interface\\CastingBar\\UI-CastingBar-Spark",
    "sparkBlendMode": "ADD", "sparkOffsetX": 0, "sparkOffsetY": 0,
    "sparkRotationMode": "AUTO", "sparkRotation": 0, "sparkHidden": "NEVER",
    "subRegions": [
        {"type": "subforeground"},
        {"type": "subbackground"},
        {
            "type": "subtext",
            "text_text": "%p",
            "text_color": [1, 1, 1, 1],
            "text_font": "Friz Quadrata TT",
            "text_fontSize": 12,
            "text_fontType": "None",
            "text_justify": "CENTER",
            "text_visible": True,
            "text_selfPoint": "AUTO",
            "anchor_point": "INNER_RIGHT",
            "anchorXOffset": 0,
            "anchorYOffset": 0,
            "text_shadowColor": [0, 0, 0, 1],
            "text_shadowXOffset": 1,
            "text_shadowYOffset": -1,
            "text_automaticWidth": "Auto",
            "text_fixedWidth": 64,
            "text_wordWrap": "WordWrap",
            "text_text_format_p_format": "timed",
            "text_text_format_p_time_precision": 1,
            "text_text_format_p_time_format": 0,
            "text_text_format_p_time_dynamic_threshold": 60,
            "text_text_format_p_time_legacy_floor": False,
        },
        {
            "type": "subtext",
            "text_text": "%n",
            "text_color": [1, 1, 1, 1],
            "text_font": "Arial Narrow",
            "text_fontSize": 6,
            "text_fontType": "None",
            "text_justify": "CENTER",
            "text_visible": True,
            "text_selfPoint": "AUTO",
            "anchor_point": "CENTER",
            "anchorXOffset": 0,
            "anchorYOffset": 0,
            "text_anchorXOffset": -10,
            "text_shadowColor": [0, 0, 0, 1],
            "text_shadowXOffset": 1,
            "text_shadowYOffset": -1,
            "text_automaticWidth": "Auto",
            "text_fixedWidth": 64,
            "text_wordWrap": "WordWrap",
            "text_text_format_n_format": "none",
        },
    ],
    "triggers": {
        "1": {
            "trigger": {
                "type": "unit",
                "event": "Cast",
                "unit": "player",
            },
            "untrigger": {},
        },
        "activeTriggerMode": -10,
    },
}


# ---------------------------------------------------------------------------
# 6c. swing_timer (aurabar) - outside the five tiers, native trigger (no addon)
#
# REVISED 2026-07-06 (later same day, Battlewrath's direct request): "I
# think the cast / swing should both be bars... The same with the swing
# timer" - supersedes the earlier icon-region decision (Template_shadow.py
# v0.12's changelog, ELEMENT_INVENTORY.md's Row D note). The old
# swing_timer_icon.schema.json/.template.json files are left on disk as
# history (never live-tested, so nothing is lost by superseding them) but
# are no longer in REGISTRY - swing_timer_aurabar is what actually gets
# built from here on.
# ---------------------------------------------------------------------------

SWING_TIMER_AURABAR_SCHEMA = {
    "$id": "swing_timer_aurabar.schema.json",
    "opportunity_type": "swing_timer",
    "title": "Swing timer (aurabar)",
    "description": (
        "Melee auto-attack swing/rhythm tracker - sits outside the five "
        "tiers (HUD_DESIGN.md, settled 2026-07-06), same category as "
        "enemy_cast. Uses WeakAuras' own NATIVE 'Swing Timer' trigger "
        "(Prototypes.lua line 4969) - no external addon dependency. An "
        "earlier assumption that this needed a separate library addon "
        "(SwingTimerAPI by Ralgathor, referenced by a live Wago pack) was "
        "checked directly against this project's installed WeakAuras "
        "source and found wrong - the native trigger is fully "
        "self-contained. REVISED 2026-07-06 (later same day): converted "
        "from icon to aurabar, and given the same 'always-shown shadow "
        "footprint' treatment as player_cast_aurabar, per Battlewrath's "
        "direct request that both bars match - see that schema's "
        "'idle-shadow mechanism' note, identical logic here."
    ),
    "region_type": "aurabar",
    "trigger": "Swing Timer",
    "type": "object",
    "required": ["name", "x", "y"],
    "properties": {
        "name": {"type": "string"},
        "hand": {
            "type": "string",
            "enum": ["main", "off", "ranged"],
            "default": "main",
            "description": "Which weapon slot to track - Types.lua's swing_types (main=MAINHANDSLOT, off=SECONDARYHANDSLOT, ranged=RANGEDSLOT). Defaults to main-hand; only one mask slot exists for this element so far - dual-wield off-hand tracking (a second bar) is a stretch enhancement for melee-class builds later, not needed for Necromancer.",
        },
        "x": {"type": "number"},
        "y": {"type": "number"},
        "width": {"type": "number", "default": 127.5},
        "height": {"type": "number", "default": 15},
    },
    "verified": (
        "Trigger type and 'hand' field confirmed directly from this "
        "project's own installed WeakAuras source (Prototypes.lua lines "
        "4969-5030 - including its own implicit show/hide test, "
        "'(inverse and duration==0) or (not inverse and duration>0)', "
        "confirming the trigger is naturally hidden when no swing is in "
        "progress - and Types.lua's swing_types line 2350), not inferred "
        "from a community pack. progressType='timed' confirmed at line "
        "5076. WeakAuras' own UI text warns results are 'inaccurate in "
        "edge cases' due to Blizzard API limitations (CAPABILITY_INVENTORY."
        "md) - accepted as-is per Battlewrath, this is a baseline, not a "
        "final answer. IDLE-SHADOW MECHANISM - ATTEMPTED THEN WITHDRAWN "
        "(2026-07-06), identical story to player_cast_aurabar.schema.json: "
        "live-tested, found backwards (hid once triggered instead of "
        "brightening), withdrawn in favor of a separate backing_plate_"
        "aurabar element doing the persistent-footprint job instead. Back "
        "to a single trigger, full alpha, normal show/hide. Timer-text "
        "placeholder ('%p', INNER_RIGHT) kept - see that file's 'verified' "
        "field for the shared writeup. COLOR SYNCED 2026-07-06: barColor "
        "set to white/untinted ([1,1,1,1]), matching the 'color' field on "
        "Battlewrath's own real in-game 'Swing Timer' recolor (decoded "
        "from the same pasted export as Cast Bar's color, both from the "
        "actually-imported v1 aura - see slot_assignment.md's timeline "
        "correction). ICON: BRIEFLY REMOVED, THEN RESTORED WITH CORRECTED "
        "UNDERSTANDING (2026-07-06) - same story and AuraBar.lua "
        "confirmation as player_cast_aurabar.schema.json's matching note, "
        "not repeated in full here. Restored to icon:true. Confirmed why "
        "it's wanted specifically for Swing Timer: with iconSource=-1, "
        "AuraBar.lua's UpdateIcon() reads self.state.icon - the Swing "
        "Timer trigger's own 'icon' state field (Prototypes.lua line "
        "~5047, init='icon', fed by GetSwingTimerInfo(hand)'s icon return "
        "value) is the swinging WEAPON's icon, per Battlewrath: 'they use "
        "the icon of what triggered them... what weapon.' Not yet "
        "rebuilt/live-tested since this correction."
    ),
}

SWING_TIMER_AURABAR_TEMPLATE = {
    "regionType": "aurabar",
    "width": "{{width}}",
    "height": "{{height}}",
    "orientation": "HORIZONTAL",
    "inverse": False,
    "alpha": 1,
    "barColor": [1, 1, 1, 1],
    "backgroundColor": [0.0, 0.0, 0.0, 0.5],
    "texture": "Blizzard",
    "textureSource": "LSM",
    "icon": True,
    "icon_side": "LEFT",
    "icon_color": [1.0, 1.0, 1.0, 1.0],
    "desaturate": False,
    "iconSource": -1,
    "displayIcon": "",
    "zoom": 0,
    "progressSource": [-1, ""],
    "adjustedMax": "", "adjustedMin": "",
    "useAdjustededMax": False, "useAdjustededMin": False,
    "spark": True,
    "sparkWidth": 4, "sparkHeight": 20, "sparkColor": [1.0, 1.0, 1.0, 1.0],
    "sparkTexture": "Interface\\CastingBar\\UI-CastingBar-Spark",
    "sparkBlendMode": "ADD", "sparkOffsetX": 0, "sparkOffsetY": 0,
    "sparkRotationMode": "AUTO", "sparkRotation": 0, "sparkHidden": "NEVER",
    "subRegions": [
        {"type": "subbackground"},
        {
            "type": "subtext",
            "text_text": "%p",
            "text_color": [1, 1, 1, 1],
            "text_font": "Friz Quadrata TT",
            "text_fontSize": 12,
            "text_fontType": "None",
            "text_justify": "CENTER",
            "text_visible": True,
            "text_selfPoint": "AUTO",
            "anchor_point": "INNER_RIGHT",
            "anchorXOffset": 0,
            "anchorYOffset": 0,
            "text_shadowColor": [0, 0, 0, 1],
            "text_shadowXOffset": 1,
            "text_shadowYOffset": -1,
        },
    ],
    "triggers": {
        "1": {
            "trigger": {
                "type": "unit",
                "event": "Swing Timer",
                "hand": "{{hand}}",
            },
            "untrigger": {},
        },
        "activeTriggerMode": -10,
    },
}


# ---------------------------------------------------------------------------
# 6d. backing_plate (aurabar) - static footprint element, sits BEHIND
# Cast Bar / Swing Timer (added 2026-07-06, replacing the withdrawn
# multi-trigger idle-shadow mechanism on those two templates)
# ---------------------------------------------------------------------------

BACKING_PLATE_AURABAR_SCHEMA = {
    "$id": "backing_plate_aurabar.schema.json",
    "opportunity_type": "backing_plate",
    "title": "Backing plate (aurabar, always shown)",
    "description": (
        "A plain, always-visible dim plate that sits BEHIND a trigger-"
        "gated bar (Cast Bar or Swing Timer) at the exact same position/"
        "size, so the element's footprint stays visible even while the "
        "real bar is hidden between casts/swings. Added 2026-07-06 to "
        "replace an earlier, more complicated fix: a second 'always-true' "
        "trigger plus a Condition directly on the Cast Bar/Swing Timer "
        "auras themselves (see player_cast_aurabar.schema.json's 'IDLE-"
        "SHADOW MECHANISM' note) - live-tested by Battlewrath and found "
        "backwards (bar hid once actually triggered). Battlewrath's own "
        "diagnosis: 'I think the fix is just a backing plate that "
        "maintains their footprint, and sits behind the bars as far as "
        "the layers go... rather than over complicate the auras.' This "
        "template is that plate: a separate, structurally simple aura, "
        "not a modification of the real bar's own trigger/condition logic."
    ),
    "region_type": "aurabar",
    "trigger": "Unit Characteristics",
    "type": "object",
    "required": ["name", "x", "y"],
    "properties": {
        "name": {"type": "string"},
        "x": {"type": "number"},
        "y": {"type": "number"},
        "width": {"type": "number", "default": 127.5},
        "height": {"type": "number", "default": 15},
    },
    "verified": (
        "Trigger: 'Unit Characteristics' (unit=player, no optional checks "
        "ticked) is unconditionally true whenever the player unit exists - "
        "confirmed directly in Prototypes.lua (line 1622+): every base "
        "field (name/realm) has test='true' with nothing else enabled, so "
        "the whole trigger is always active. Used here as the aura's SOLE "
        "trigger (no second trigger, no activeTriggerMode combination, no "
        "Condition) - deliberately as simple as possible, since the "
        "withdrawn idle-shadow mechanism's bug lived specifically in the "
        "multi-trigger 'first_active' combination logic, not in the "
        "always-true trigger itself. Since this trigger never sets "
        "duration/expirationTime, AuraBar.lua's own fallback ('duration ~= "
        "0 and remaining/duration or 0') reads progress as 0% - so the "
        "plate shows its backgroundColor/border only, never a colored "
        "fill, which is exactly the flat 'plate' look wanted (no subtext "
        "either - the real bar on top already carries the value/timer "
        "text). frameStrata=2 ('BACKGROUND', confirmed in Types.lua's "
        "frame_strata_types - 1=Inherited, 2=BACKGROUND, 3=LOW, 4=MEDIUM, "
        "5=HIGH, 6=DIALOG, 7=FULLSCREEN, 8=FULLSCREEN_DIALOG, 9=TOOLTIP) "
        "is set explicitly so it renders behind the real bar (which stays "
        "at frameStrata=1/Inherited, same as every other template in this "
        "project) - not yet independently confirmed live that Inherited "
        "actually renders above BACKGROUND in every case, but it's the "
        "correct directional choice per WeakAuras' own documented strata "
        "ordering. "
        "ALPHA CORRECTED 2026-07-06 (ninth pass), after live-testing v8: "
        "Battlewrath's first live look at the idle state ('the backing "
        "plate doesn't match the darkness of the runic bar colour... "
        "currently empty as the runic power is low... same darkness is "
        "seen [for mana]... cohesive between both bars as a background "
        "colour') surfaced that this template's alpha=0.35 was compounding "
        "with backgroundColor's own 0.5 alpha, landing around 0.175 "
        "effective darkness - visibly lighter than Mana/Runic Power's "
        "natural empty look (which sits at region alpha=1, so their "
        "backgroundColor's 0.5 IS the effective darkness, unmultiplied). "
        "Confirmed aligned with a second screenshot showing Mana/Runic "
        "Power and Cast Bar/Swing Timer already cohesive with each other "
        "when actively in use - so the mismatch was isolated to this "
        "template's alpha, not a broader color problem. Fixed: alpha "
        "1 (matching the real bars), relying solely on the existing "
        "backgroundColor=[0,0,0,0.5] for the dimming - now the identical "
        "mechanism the real bars use for their own empty/low look, not a "
        "second, different one. Not yet live-tested since this correction."
    ),
}

BACKING_PLATE_AURABAR_TEMPLATE = {
    "regionType": "aurabar",
    "width": "{{width}}",
    "height": "{{height}}",
    "orientation": "HORIZONTAL",
    "inverse": False,
    "alpha": 1,
    "frameStrata": 2,
    "barColor": [1, 1, 1, 1],
    "backgroundColor": [0.0, 0.0, 0.0, 0.5],
    "texture": "Blizzard",
    "textureSource": "LSM",
    "icon": False,
    "desaturate": False,
    "iconSource": -1,
    "displayIcon": "",
    "zoom": 0,
    "progressSource": [-1, ""],
    "adjustedMax": "", "adjustedMin": "",
    "useAdjustededMax": False, "useAdjustededMin": False,
    "spark": False,
    "subRegions": [{"type": "subbackground"}],
    "triggers": {
        "1": {
            "trigger": {
                "type": "unit",
                "event": "Unit Characteristics",
                "unit": "player",
            },
            "untrigger": {},
        },
        "activeTriggerMode": -10,
    },
}


# ---------------------------------------------------------------------------
# 7. pet_summon_countdown (icon) - class-specific pet tracker
# ---------------------------------------------------------------------------

PET_SUMMON_COUNTDOWN_ICON_SCHEMA = {
    "$id": "pet_summon_countdown_icon.schema.json",
    "opportunity_type": "pet_summon_countdown",
    "title": "Pet/minion summon countdown (icon)",
    "description": (
        "Time-since-summon countdown for a minion with no stable per-unit "
        "token (Necromancer Animate spells, Wild Imps, Army of the Dead). "
        "Not a real HP query - a known-duration countdown, per USE_CASE.md's "
        "'Tracking non-directly-controlled pets' research and the real "
        "db.ascension.gg Necromancer Temp-Summon Tracker it's modeled on."
    ),
    "region_type": "icon",
    "trigger": "Cooldown Progress (Spell), keyed to a SPELL_..._SUMMON combat-log event",
    "type": "object",
    "required": ["name", "summon_spell_id", "duration_seconds", "x", "y"],
    "properties": {
        "name": {"type": "string"},
        "summon_spell_id": {"type": ["string", "integer"]},
        "duration_seconds": {"type": "number", "description": "Hardcoded known duration for this minion type (e.g. 15/30/35s per the community aura's own per-type values)."},
        "x": {"type": "number"},
        "y": {"type": "number"},
        "width": {"type": "number", "default": 30},
        "height": {"type": "number", "default": 20},
    },
    "verified": "Pattern confirmed against a real, currently-used community aura (Walmartpjs' Necromancer Temp-Summon Tracker, db.ascension.gg) - see USE_CASE.md. Not yet built or live-tested by this project directly.",
}

PET_SUMMON_COUNTDOWN_ICON_TEMPLATE = {
    "regionType": "icon",
    "width": "{{width}}",
    "height": "{{height}}",
    "color": [1, 1, 1, 1],
    "desaturate": False,
    "iconSource": -1,
    "displayIcon": "",
    "cooldown": True,
    "cooldownEdge": False,
    "inverse": False,
    "zoom": 0,
    "keepAspectRatio": False,
    "progressSource": [-1, ""],
    "adjustedMax": "", "adjustedMin": "",
    "useAdjustededMax": False, "useAdjustededMin": False,
    "subRegions": [{"type": "subbackground"}],
    "triggers": {
        "1": {
            "trigger": {
                "type": "combatlog",
                "event": "Combat Log",
                "subeventSuffix": "_SUMMON",
                "spellIds": ["{{summon_spell_id}}"],
                "use_spellId": True,
                "duration": "{{duration_seconds}}",
                "use_duration": True,
            },
            "untrigger": {},
        },
        "activeTriggerMode": -10,
    },
}


# ---------------------------------------------------------------------------
# stack_counter overlay fragment - the actual subRegions entry to append
# ---------------------------------------------------------------------------

STACK_COUNTER_OVERLAY_FRAGMENT = {
    "type": "subtext",
    "text_text": "%s",
    "text_color": [1, 1, 1, 1],
    "text_font": "Friz Quadrata TT",
    "text_fontSize": "{{font_size}}",
    "text_fontType": "OUTLINE",
    "text_visible": True,
    "text_justify": "CENTER",
    "text_selfPoint": "AUTO",
    "anchor_point": "{{anchor_point}}",
    "anchorXOffset": 0,
    "anchorYOffset": 0,
    "text_shadowColor": [0, 0, 0, 1],
    "text_shadowXOffset": 0,
    "text_shadowYOffset": 0,
    "text_automaticWidth": "Auto",
    "text_fixedWidth": 64,
    "text_wordWrap": "WordWrap",
}

# ---------------------------------------------------------------------------
# class_accent_tick_end - a named, reusable design-language fragment
# ---------------------------------------------------------------------------
# Added 2026-07-06 (tenth/eleventh pass), per Battlewrath: "make that tick a
# known element ... as that can be a subtle design language through all the
# UI's." A permanent subtick end-cap, placed at AtPercent 100 (the bar's own
# current max, regardless of level/gear - see Tick.lua's UpdateTickPlacementOne),
# colored with whatever class's accent is passed in. Originally built as a
# one-off inline dict inside template_filler.py's resource_threshold_aurabar
# handling (for Mana/Runic Power specifically); promoted here so any future
# aurabar template, on any class, can append the same marker via one shared
# fragment instead of a re-copied dict.
#
# CORRECTED 2026-07-06 (eleventh pass) after a real live-test bug: the first
# version of this fragment (and the pre-existing threshold_value subtick,
# which shares the same underlying shape) omitted 3 fields present in
# SubRegionTypes/Tick.lua's own default() table - progressSources,
# automatic_length, tick_texture - and stored tick_placements as a JSON
# number (100) rather than the string ("100") WeakAuras itself writes once
# a subtick round-trips through its own options UI. Battlewrath reported
# the in-game placement read "50" (Tick.lua's own stock default,
# tick_placements = {"50"}) until manually re-entered as 100; a real
# re-exported aura pasted back and decoded confirmed the exact gap - our
# fragment was missing those 3 keys, which is consistent with WeakAuras'
# load-time defaults-merge treating an incompletely-specified subRegion as
# needing its own stock defaults for the parts it can't recognize as fully
# authored. Fixed by matching Tick.lua's default() table completely.
CLASS_ACCENT_TICK_END_SCHEMA = {
    "$id": "class_accent_tick_end.schema.json",
    "title": "Class accent tick - permanent end-cap marker",
    "description": "A permanent subtick, placed at the bar's own 100% (AtPercent) position, colored with the owning class's accent - marks a resource bar's own max extent/range of travel so its fill % has a reference point even when it visually abuts another element (e.g. a backing plate) with matching background darkness. Distinct from a threshold_value marker (AtValue, a specific number) - this one is always 'the end of this bar,' not tied to any particular resource value.",
    "type": "object",
    "properties": {
        "end_cap_color": {
            "type": "array",
            "description": "RGBA, typically the owning class's theme.json accent_rgba.",
        },
    },
    "usage_rule": "Scoped 2026-07-06 (twelfth pass), per Battlewrath: only belongs on a bar that sits at a console's outer position and touches ANOTHER element at the console's shared center seam (e.g. Mana/Runic Power on the left touching Cast Bar/Swing Timer's backing plates at the middle) - confirmed live with a real screenshot (Mana's bar: green tick at its own max extent, distinct from the blue current-value fill). NOT a blanket default for every aurabar - a standalone bar with open space/game background on both sides has no adjacent element to visually fuse into in the first place, so it doesn't need a reference marker. Cast Bar/Swing Timer are the concrete counter-example: they already end cleanly against their own backing plate and then the game background, so they get no end-cap at all.",
    "verified": "SubRegionTypes/Tick.lua read directly. tick_placement_mode='AtPercent' resolves 'minValue + tick_placements[i]*valueRange/100' against the bar's live GetMinMaxProgress() (UpdateTickPlacementOne, ~line 272) - placement 100 always lands at the bar's own current true max, independent of any other region (confirmed: the width scaled against is self.parentMajorSize, from self.parent.bar:GetRealSize(), where self.parent is THIS aurabar - no shared reference with a backing plate or any sibling element). FIELD-PARITY BUG, found and fixed 2026-07-06 (eleventh pass) via a real live-test round-trip: Battlewrath imported a fragment missing progressSources/automatic_length/tick_texture (present in Tick.lua's default()) and with tick_placements as a number; in-game the tick showed the stock default placement (50) until manually re-entered, and Battlewrath's own re-exported aura (decoded via weakaura_codec.py) confirmed real WeakAuras stores tick_placements as a string once committed through its options UI. This fragment now matches Tick.lua's default() table field-for-field, with tick_placements pre-set as the string '100' (not user-configurable - this fragment is always 'the end of the bar', unlike threshold_value).",
}

CLASS_ACCENT_TICK_END_FRAGMENT = {
    "type": "subtick",
    "tick_visible": True,
    "tick_color": "{{end_cap_color}}",
    "tick_placement_mode": "AtPercent",
    "tick_placements": ["100"],
    "progressSources": [[-2, ""]],
    "automatic_length": True,
    "tick_thickness": 2,
    "tick_length": 30,
    "use_texture": False,
    "tick_texture": "Interface\\CastingBar\\UI-CastingBar-Spark",
    "tick_blend_mode": "ADD",
    "tick_desaturate": False,
    "tick_rotation": 0,
    "tick_xOffset": 0,
    "tick_yOffset": 0,
    "tick_mirror": False,
}

# ---------------------------------------------------------------------------
# Registry - drives both file generation and the filler's lookup
# ---------------------------------------------------------------------------

REGISTRY = {
    "cooldown_tracker_icon": (COOLDOWN_TRACKER_ICON_SCHEMA, COOLDOWN_TRACKER_ICON_TEMPLATE),
    "proc_alert_icon": (PROC_ALERT_ICON_SCHEMA, PROC_ALERT_ICON_TEMPLATE),
    "buff_uptime_icon": (BUFF_UPTIME_ICON_SCHEMA, BUFF_UPTIME_ICON_TEMPLATE),
    "buff_uptime_aurabar": (BUFF_UPTIME_AURABAR_SCHEMA, BUFF_UPTIME_AURABAR_TEMPLATE),
    "resource_threshold_aurabar": (RESOURCE_THRESHOLD_AURABAR_SCHEMA, RESOURCE_THRESHOLD_AURABAR_TEMPLATE),
    "missing_buff_icon": (MISSING_BUFF_ICON_SCHEMA, MISSING_BUFF_ICON_TEMPLATE),
    "enemy_cast_aurabar": (ENEMY_CAST_AURABAR_SCHEMA, ENEMY_CAST_AURABAR_TEMPLATE),
    "player_cast_aurabar": (PLAYER_CAST_AURABAR_SCHEMA, PLAYER_CAST_AURABAR_TEMPLATE),
    "swing_timer_aurabar": (SWING_TIMER_AURABAR_SCHEMA, SWING_TIMER_AURABAR_TEMPLATE),
    "backing_plate_aurabar": (BACKING_PLATE_AURABAR_SCHEMA, BACKING_PLATE_AURABAR_TEMPLATE),
    "pet_summon_countdown_icon": (PET_SUMMON_COUNTDOWN_ICON_SCHEMA, PET_SUMMON_COUNTDOWN_ICON_TEMPLATE),
}

FRAGMENTS = {
    "glow_source": GLOW_SOURCE_SCHEMA,
    "stack_counter_overlay": STACK_COUNTER_OVERLAY_SCHEMA,
    "class_accent_tick_end": CLASS_ACCENT_TICK_END_SCHEMA,
    "power_threshold_effect": POWER_THRESHOLD_EFFECT_SCHEMA,
}

FRAGMENT_TEMPLATES = {
    "stack_counter_overlay": STACK_COUNTER_OVERLAY_FRAGMENT,
    "class_accent_tick_end": CLASS_ACCENT_TICK_END_FRAGMENT,
}


def write_all():
    os.makedirs(SCHEMA_DIR, exist_ok=True)
    os.makedirs(TEMPLATE_DIR, exist_ok=True)

    for name, (schema, template) in REGISTRY.items():
        with open(os.path.join(SCHEMA_DIR, f"{name}.schema.json"), "w") as f:
            json.dump(schema, f, indent=2, sort_keys=False)
            f.write("\n")
        with open(os.path.join(TEMPLATE_DIR, f"{name}.template.json"), "w") as f:
            json.dump(template, f, indent=2, sort_keys=False)
            f.write("\n")

    for name, schema in FRAGMENTS.items():
        with open(os.path.join(SCHEMA_DIR, f"{name}.schema.json"), "w") as f:
            json.dump(schema, f, indent=2, sort_keys=False)
            f.write("\n")

    for name, template in FRAGMENT_TEMPLATES.items():
        with open(os.path.join(TEMPLATE_DIR, f"{name}.template.json"), "w") as f:
            json.dump(template, f, indent=2, sort_keys=False)
            f.write("\n")

    base = base_envelope()
    with open(os.path.join(TEMPLATE_DIR, "_base_envelope.template.json"), "w") as f:
        json.dump(base, f, indent=2, sort_keys=False)
        f.write("\n")

    print(f"Wrote {len(REGISTRY)} template schema/template pairs, "
          f"{len(FRAGMENTS)} fragment schemas, and the base envelope.")


if __name__ == "__main__":
    write_all()
