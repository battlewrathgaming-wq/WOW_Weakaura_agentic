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
        "in place, not spawn a separate icon. Modeled as a LIST - "
        "ORIGINALLY scoped 2026-07-04 to '1 effect is fine for now,' but "
        "REVISED 2026-07-10: Battlewrath's real, live-tested Tormented "
        "Souls v4 build stacks TWO entries simultaneously on one icon "
        "(buff_uptime for the ability's own granted buff, "
        "external_empower for an unrelated buff that empowers it) - "
        "proving the multi-entry case is real, not just theoretical. "
        "template_filler.py's glow_source handling now iterates every "
        "entry in the list (was previously hardcoded to entry[0] only - "
        "see template_filler.py's own inline note for that fix)."
    ),
    "type": "array",
    "maxItems_note": "No hard cap - confirmed live with 2 simultaneous entries (Tormented Souls v4); may grow further as more combinations get built and tested.",
    "items": {
        "type": "object",
        "required": ["opportunity_type", "spell_id"],
        "properties": {
            "opportunity_type": {
                "type": "string",
                "enum": ["proc_alert", "buff_uptime", "external_empower", "target_debuff_presence"],
                "description": "Which of the four glow/texture-eligible opportunity types this second spell is.",
            },
            "spell_id": {
                "type": ["string", "integer"],
                "description": "The proc/buff/debuff spell ID that should brighten (or texture-overlay) the parent icon when active.",
            },
            "use_exact_spell_id": {"type": "boolean", "default": True},
            "glow_color": {
                "type": "array",
                "description": (
                    "REQUIRED when opportunity_type is 'target_debuff_"
                    "presence', unused otherwise. RGBA for the internal "
                    "Pixel-type subglow (see 'verified' field's ADDED "
                    "2026-07-10 (third pass) note for the mechanism). Not "
                    "defaulted to accent_color - Battlewrath's own real "
                    "captured example color-codes this signal PURPLE "
                    "([0.4, 0.0235, 0.7686, 1]) as a project-wide "
                    "'offensive/debuff-presence tracker' convention, "
                    "independent of any class's own theme accent."
                ),
            },
            "texture_color": {
                "type": "array",
                "description": (
                    "REQUIRED when opportunity_type is 'external_empower', "
                    "unused otherwise. RGBA tint for the empowerment "
                    "subtexture overlay. Deliberately NOT defaulted to the "
                    "parent template's own accent_color (unlike "
                    "buff_uptime's glow_color reuse) - an external "
                    "empowering buff typically carries its OWN visual "
                    "identity, independent of the icon's class accent "
                    "(confirmed: Soul Infusion's real captured color, "
                    "bright cyan [0.012, 1, 0.847, 1], does not match "
                    "Reaper's own theme accent, a darker teal-green "
                    "#0a876b) - so this must be explicitly supplied per "
                    "empowering buff, not inherited."
                ),
            },
            "texture_path": {
                "type": "string",
                "default": "Interface\\Addons\\WeakAuras\\PowerAurasMedia\\Auras\\Aura1",
                "description": (
                    "Used only for 'external_empower' - the subtexture's "
                    "own texture file. Defaults to the exact path "
                    "confirmed in Battlewrath's real Soul Infusion build - "
                    "a plain ambient ring texture, established here as the "
                    "standard empowerment visual language (same precedent "
                    "as border_edge defaulting to 'Blizzard Dialog' and "
                    "glow_source's buff_uptime branch defaulting to the "
                    "Pixel glow type) - override only if a specific future "
                    "empowerment case needs a different real, evidenced "
                    "texture."
                ),
            },
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
        "version (cType=='number'), confirmed the same way. "
        "REVISED 2026-07-10: the 'buff_uptime' branch's glow mechanism "
        "changed from the plain sub.N.glow subRegion toggle to "
        "'glowexternal' (LibCustomGlow's Pixel-type border glow, applied "
        "directly to the aura's own frame rather than a subRegion), per "
        "Battlewrath's live-built and live-tested Reaper 'Tormented Souls' "
        "aura - this reads as 'confirmation this effect is active' rather "
        "than proc_alert's 'a different ability's proc empowering this "
        "one,' and Battlewrath specifically wanted the Pixel border-trace "
        "look, colored to the parent template's own accent_color (class "
        "accent hex), not a hand-picked one-off. Unlike sub.N.glow (a "
        "plain boolean property that auto-reverts to its base value once "
        "its Condition stops being true), glowexternal is an IMPERATIVE "
        "action (glow_action: 'show'/'hide' on LibCustomGlow) with no "
        "automatic revert - confirmed the hard way live, in-game: the "
        "first build only wired the 'show' half, so the glow started once "
        "and never stopped. Fix, also confirmed live: a second Condition, "
        "same check inverted (trigger's own 'show'==0), explicitly firing "
        "glow_action:'hide' on the same glow_frame. template_filler.py's "
        "buff_uptime branch now generates both conditions as a pair. "
        "proc_alert's own mechanism is UNCHANGED by this revision - still "
        "the older sub.N.glow toggle - since Battlewrath's ask was "
        "specifically about the buff-active-confirmation case, not the "
        "proc-opportunity one; the two are deliberately kept visually and "
        "mechanically distinct. "
        "ADDED 2026-07-10 (second pass, same day): 'external_empower' - "
        "decoded directly from Battlewrath's real, live-built Tormented "
        "Souls v4 export (weakaura_codec.py). Real trigger 4: {type: "
        "'aura2', unit: 'player', debuffType: 'HELPFUL', auraspellids: "
        "['803031'] (Soul Infusion), useExactSpellId: true, ownOnly: "
        "true, useStacks: true, stacksOperator: '<=', stacks: '1'}. "
        "Battlewrath's own framing: 'a way to self contain a threshold "
        "resource amount on the same item... a subtle texture that shows "
        "it's empowered... rather than being flashy for attention... less "
        "dramatics, but gives you reference to wait for that state.' The "
        "useStacks/stacksOperator/stacks fields are DELIBERATELY NOT "
        "reproduced in template_filler.py's generated trigger - "
        "Battlewrath's own words, 'canceling out conditions,' describe "
        "these as a neutralized WeakAuras-UI artifact (stacks<=1 is "
        "trivially true for a non-stacking buff, so it rides along "
        "harmlessly rather than doing real filtering); reproducing it "
        "literally would risk a real bug for any FUTURE empowering buff "
        "that genuinely stacks past 1 (stacks<=1 would then hide the "
        "texture at higher stacks, backwards from intent) - so the "
        "formalized version is a plain aura2 presence check, functionally "
        "identical for Soul Infusion and safer for a stacking case later. "
        "Real subRegion: a subtexture, textureTexture 'Interface\\Addons\\"
        "WeakAuras\\PowerAurasMedia\\Auras\\Aura1', textureBlendMode "
        "'ADD', textureColor [0.012, 1, 0.847, 1] (bright cyan - NOT "
        "Reaper's own theme accent, #0a876b/darker teal-green - "
        "confirming this is the EMPOWERING BUFF's own visual identity, "
        "not the icon's class accent), 32x32, anchor_area 'ALL' (covers "
        "the whole icon), self_point/anchor_point CENTER. Real "
        "conditions: trigger-4-show==1 -> sub.N.textureVisible=true, "
        "trigger-4-show==0 -> sub.N.textureVisible=false - BOTH states "
        "explicit (unlike desaturate's inferred-off convention), because "
        "this subtexture's own baseline textureVisible is true (not "
        "false), so the 'hide' half has to be stated or it would never "
        "revert - a declarative property toggle (like sub.N.glow), NOT "
        "glowexternal's imperative show/hide-action mechanism, even "
        "though both need a paired pair of Conditions for a different "
        "reason each (glowexternal because it has no auto-revert at all; "
        "this because the property's own default is 'on', not 'off'). "
        "ADDED 2026-07-10 (third pass, same day) - 'target_debuff_"
        "presence' AND a key mechanism correction, both decoded from "
        "Battlewrath's real, live-built and live-tested 'Murder' "
        "(502679) Rotation-tier aura via weakaura_codec.py. Battlewrath's "
        "own framing: 'I didn't know I can declare an internal glow "
        "effect, so I used the external and pointed it on it's self. "
        "I've since learned about making a glow, internal, but turned "
        "off. And then a condition turning it onto visible.' "
        "MECHANISM CORRECTION: glowexternal's frame-selector-pointed-at-"
        "itself hack (used for buff_uptime above) was NEVER actually "
        "necessary to get a Pixel-type border-trace look - the real "
        "Murder capture proves an ordinary INTERNAL subglow subRegion "
        "can itself be configured with glowType:'Pixel', useGlowColor: "
        "true, and a custom glowColor (not just the plain 'buttonOverlay' "
        "type proc_alert's own sub.N.glow branch happens to use), then "
        "toggled via the exact same declarative 'sub.N.glow' property "
        "Condition proc_alert already uses - a single Condition (check "
        "trigger show==1 -> sub.N.glow:true), NO paired hide needed, "
        "confirmed by the real capture having only ONE condition for "
        "this signal (auto-revert, same declarative-property class as "
        "desaturate/proc_alert's sub.N.glow - NOT glowexternal's "
        "imperative, no-auto-revert class). This is simpler than "
        "glowexternal on every axis (no frame_frame_type/glow_frame "
        "self-targeting, no imperative glow_action pair, no risk of the "
        "'glow starts and never stops' bug class already hit once on "
        "buff_uptime) - kept as a documented alternative rather than "
        "retroactively rewriting buff_uptime's own already-shipped, "
        "working glowexternal mechanism (Tormented Souls is live and "
        "correct as built); future opportunity_types needing a border-"
        "glow confirmation signal should default to THIS simpler "
        "internal-subglow approach unless a real reason favors "
        "glowexternal specifically. "
        "target_debuff_presence ITSELF: a boolean CONDITION CHECK, not a "
        "DoT/duration tracker - Battlewrath's own words: 'this checks if "
        "my target has my debuff on it. This is not a DOT tracker in the "
        "broad sense. More a condition checker.' Real trigger 3: {type: "
        "'aura2', unit: 'target', debuffType: 'HARMFUL', auraspellids: "
        "['560421'], useExactSpellId: true, ownOnly: true} - unit:'target' "
        "is the load-bearing difference from every other aura2 trigger in "
        "this project so far (all previously unit:'player'); the debuff "
        "is one the PLAYER applies (ownOnly:true) but the presence check "
        "reads the TARGET's own aura list, not the player's. Several "
        "fields on the real captured trigger (use_absorbMode, "
        "genericShowOn/use_genericShowOn/event:'Cooldown Progress "
        "(Spell)', use_track, use_unit, use_spellName) are the same class "
        "of harmless WeakAuras-UI leftover already documented repeatedly "
        "in this project for aura2 triggers (inert fields from switching "
        "the trigger-type dropdown) - deliberately not reproduced. Real "
        "subglow subRegion: glowType 'Pixel', useGlowColor true, glowColor "
        "[0.4, 0.0235, 0.7686, 1] - purple, Battlewrath's own stated "
        "color-code for this as an 'offensive tracker,' a NEW project-wide "
        "convention distinct from any class's own theme accent (parallel "
        "to Soul Infusion's cyan being the empowering buff's own identity, "
        "not Reaper's theme color)."
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

PRESS_WASH_EFFECT_SCHEMA = {
    "$id": "press_wash_effect.schema.json",
    "title": "Press-wash effect fragment",
    "description": (
        "Not a standalone template - an OPTIONAL extra trigger (Combat Log, "
        "SPELL_CAST_SUCCESS, filtered to this icon's OWN spell_id) "
        "attachable to any icon-shaped template, giving per-ability 'I "
        "pressed this and it actioned' feedback - independent per icon, "
        "never a shared/global flash. Added 2026-07-06, per Battlewrath's "
        "piano-key analogy: 'press a key and get a response.' Distinct "
        "from power_threshold (opportunity - can I afford this right now) "
        "and glow_source (a DIFFERENT ability's proc empowering this one) - "
        "this fragment is pure response feedback to the player's OWN "
        "action, and is scoped ONLY to abilities that don't already get a "
        "cooldown sweep as their response signal (Battlewrath, 2026-07-06: "
        "'those with cooldowns don't need it, as their response is going "
        "on cooldown / desaturation'). Ties into the icon's own base "
        "'color' field (a faint mix toward the class accent, not a "
        "separate overlay - subforeground/subbackground on icon regions "
        "have no configurable fields, confirmed via ICON_REGION_OPTIONS.md) "
        "rather than a scale/zoom animation, matching Battlewrath's most "
        "concrete reference point: the native Blizzard action-button "
        "press highlight (a faint, neutral wash, not the golden proc-glow "
        "look) - 'a very faint class hex based wash on the button when "
        "YOUR spell triggers on the event log.'"
    ),
    "type": "object",
    "properties": {
        "wash_alpha": {
            "type": "number",
            "default": 0.3,
            "description": "Mix fraction toward the icon's own accent_color, blended against white (untinted) - NOT the region's overall alpha/opacity (that stays 1 throughout, so the icon never fades/flickers transparent, only tints). 0.3 = 30%, Battlewrath's confirmed starting value (2026-07-06).",
        },
        "duration": {
            "type": "number",
            "default": 0.3,
            "description": "Seconds before auto-revert. Combat Log is a 'timedrequired' trigger category (GenericTrigger.lua line 3739) - WeakAuras reads this straight off trigger.duration and auto-hides via automaticAutoHide (GenericTrigger.lua line 1696-1700), no custom Lua or manual revert Condition needed. 0.3s, Battlewrath's confirmed starting value (2026-07-06).",
        },
    },
    "verified": (
        "Timed auto-revert mechanism confirmed directly from "
        "GenericTrigger.lua: line 3739 ('Combat Log' prototype entry has "
        "timedrequired=true), line 1696-1700 (timedrequired branch sets "
        "automaticAutoHide=true and duration=tonumber(trigger.duration or "
        "'1')), and Private.ActivateEvent/EndEvent (lines 528-561, 451-461) "
        "confirming state.show flips true then automatically false again "
        "once expirationTime passes - no polling or custom code required. "
        "Color-property Condition shape (a 4-element {r,g,b,a} table, "
        "property path 'color' directly - a top-level icon field, not a "
        "subRegion) confirmed directly from Conditions.lua's "
        "SerializeValueForCode 'color' branch (line 104-110) and "
        "formatValueForCall's 'color' branch (line 174-177). DISJUNCTIVE "
        "FIX (2026-07-06, reasoned before building): WeakAuras.lua line "
        "3109 defaults an aura's multi-trigger 'disjunctive' combination to "
        "'all' (AND) unless set otherwise. power_threshold's own second "
        "trigger (Power, a continuous status always active) never needed "
        "to touch this - AND-combining two perpetually-active triggers is "
        "a no-op. This fragment's trigger is genuinely momentary (0.3s per "
        "cast), so template_filler.py explicitly sets disjunctive='any' "
        "whenever press_wash is applied - otherwise the icon's overall "
        "visibility would require BOTH triggers active simultaneously, "
        "hiding it except during that 0.3s flash. "
        "TRIGGER FILTER SHAPE - CORRECTED 2026-07-06 after a real in-game "
        "test (v2, pasted and decoded). The original combatlog trigger "
        "copied proc_alert_icon/glow_source's existing spellIds+"
        "use_spellId=true shape (itself flagged there as 'not "
        "independently re-verified'), with no source-unit filter at all. "
        "Both were wrong in practice: (1) missing sourceUnit/use_sourceUnit "
        "meant the trigger matched Combat Log events from ANY unit, not "
        "just the player ('they all landed with no spell config... firing "
        "to any combat event' - Battlewrath); (2) Battlewrath's real fix "
        "uses use_spellName=true + spellName=[name] instead of ID-based "
        "matching - deliberately, not as a bug workaround: 'Spell ID can "
        "be a source. But I made it generic incase the ranks effect "
        "things. So targetted the spell name' - different ranks of the "
        "same spell carry different spell IDs but the same name, so name-"
        "based matching is robust across ranks where ID-based would only "
        "catch one specific rank. Both fixes applied: use_sourceUnit=true/"
        "sourceUnit='player', use_spellName=true/spellName=[name], "
        "use_spellId=false. OPEN QUESTION, not yet resolved: Battlewrath's "
        "real test also flipped subeventSuffix to '_CAST_START' and "
        "reported Lichfrost repeated correctly but Crypt Swarm/Command: "
        "Undead didn't fire at all under that suffix - hypothesis (not "
        "confirmed) is that '_CAST_START' only fires for casts with a "
        "visible windup, while purely instant abilities go straight to "
        "'_CAST_SUCCESS' with no '_CAST_START' event. Kept at "
        "'_CAST_SUCCESS' (universal for instant AND windup casts) pending "
        "a live re-test of this specific hypothesis."
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
        "press_wash": {
            "$ref": "press_wash_effect.schema.json",
            "description": "Optional - see press-wash-effect fragment. Per-press 'I touched this' feedback via a faint class-accent tint on cast-success, independent per ability. Scope: only abilities without a real cooldown sweep need this (their cooldown IS the response signal already) - see the fragment's own description.",
        },
        "desaturate_on_cooldown": {
            "type": "boolean",
            "default": False,
            "description": (
                "Added 2026-07-09, per Battlewrath's request for Skeletal "
                "Archers (805040): 'Show when available. Then desaturate "
                "whilst on cooldown... see if this can be handled as one "
                "WA item, instead of 2 (backplate vs live).' When true, "
                "adds a single Condition on this template's OWN existing "
                "trigger 1 (Cooldown Progress (Spell)) - no second trigger, "
                "no backing_plate_icon pairing needed. Confirms the answer "
                "to Battlewrath's question is yes: one WA item is enough, "
                "since the Cooldown Progress trigger already exposes a "
                "real 'duration' state field distinguishing on-cooldown "
                "(duration > 0) from available (duration == 0) - see "
                "'verified' below."
            ),
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
        "Swarm/Command: Undead. "
        "desaturate_on_cooldown CONFIRMED 2026-07-09 by direct source read "
        "of Prototypes.lua's 'Cooldown Progress (Spell)' init function "
        "(lines 3742-3900ish): the non-charge-tracking branch sets "
        "'state.duration = duration' every update, where 'duration' comes "
        "straight from 'WeakAuras.GetSpellCooldown(...)' - 0 whenever the "
        "ability is off cooldown/ready, the real cooldown length (seconds) "
        "whenever it's actively cooling down. Since this template's own "
        "trigger doesn't set 'use_showgcd' (left unticked, same as every "
        "other cooldown_tracker_icon consumer), 'duration' reflects the "
        "real ability cooldown only, never the shared GCD sweep - so this "
        "doesn't flicker desaturated on every global cooldown. The "
        "Condition mechanism itself (a numeric check against a trigger's "
        "own state field, cType=='number' in Conditions.lua) is the exact "
        "same one already independently confirmed for power_threshold's "
        "own desaturate Condition - the only difference here is checking "
        "'duration' on trigger 1 ITSELF rather than a separate Power "
        "trigger, which needs no second trigger index at all."
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
            # border_edge changed from "Square Full White" to "Blizzard
            # Dialog" per Battlewrath's live-tested Reaper "Tormented Souls"
            # build (2026-07-10) - a subtler, cleaner edge texture for the
            # rotation-icon border language than the old flat white square.
            "type": "subborder",
            "border_size": 2,
            "border_color": "{{accent_color}}",
            "border_visible": True,
            "border_edge": "Blizzard Dialog",
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
# 1b. resource_spender_icon - self-contained spender + its own resulting
# buff timer, in ONE aura
# ---------------------------------------------------------------------------
# Added 2026-07-10, formalizing Reaper's hand-built, live-tested "Tormented
# Souls" aura (Battlewrath's own words: "Tormented soul, is a tank
# defensive, but fits in the rotation... Requires Reaped soul. Per reaped
# soul, it gives a stack when it consumes them... This self contains the
# life cycle of - Owning it's foot print (Desaturated), Changing color
# when available (Desaturation falls off - available), Shows stack count
# whilst the buff is active"). Battlewrath's own final confirmed 5-state
# description: "No resource, no buff = desaturated footprint. Enough
# resource, not used = remains saturated. Used = stack count + subtle
# boarder glow. Used and expired, but; Has no resource to use = desaturated.
# Has resource to use = not saturated."
#
# Distinct from cooldown_tracker_icon: that template's trigger ("Cooldown
# Progress (Spell)") is a pure timer, blind to resource availability - a
# resource gate has to be bolted on separately via power_threshold (which
# itself only handles a LINEAR power percent/flat cost, e.g. "30 Runic
# Power"). Tormented Souls isn't cost-gated that way - it's gated on
# discrete stacks of a reagent-like resource (Reaped Soul), which "Action
# Usable" already resolves natively as one real castability boolean
# (resource AND cooldown combined - whatever the server considers "can I
# press this"), matching this project's earlier, explicit correction
# ("'Action Usable' is the right primitive here specifically because the
# gate is resource-based, not a timer").
#
# Structurally, this is TWO already-proven pieces combined, not a new
# mechanism: (1) a new base trigger pair (Action Usable, showOnReady +
# showOnCooldown/inverse, disjunctive:any - the exact shape decoded from
# Battlewrath's real, live-confirmed v3 export), driving a single fixed
# desaturate Condition off trigger 2's own "show" state; (2) the EXISTING
# glow_source fragment's "buff_uptime" branch (glowexternal Pixel border
# glow, paired show/hide conditions), unchanged, just required here rather
# than optional, since tracking the ability's OWN resulting buff is the
# entire point of this capability rather than a bolt-on. This means
# template_filler.py needed ZERO new code for this template - the generic,
# template-name-unconditional glow_source block (see its own "REVISED
# 2026-07-10" note) already produces exactly the right trigger 3 + paired
# conditions shape when attached here.
RESOURCE_SPENDER_ICON_SCHEMA = {
    "$id": "resource_spender_icon.schema.json",
    "opportunity_type": "resource_spender",
    "title": "Resource spender (icon, self-contained action + resulting buff)",
    "description": (
        "A reagent/stack-gated spender ability that ALSO grants its own "
        "tracked buff on use - one self-contained aura covers the full "
        "action->result lifecycle (castable, on cooldown/out of resource, "
        "used/buff active, buff expired) with no companion aura needed. "
        "Two Action Usable triggers (ready/cooldown pair) drive desaturate; "
        "a required glow_source entry (opportunity_type: buff_uptime) "
        "tracks the ability's OWN granted buff via the already-proven "
        "glowexternal mechanism plus a built-in stack-count readout. Use "
        "cooldown_tracker_icon instead for a plain-timer ability, or add "
        "power_threshold to cooldown_tracker_icon for a linear power-cost "
        "ability with no resulting buff of its own to track. As of "
        "2026-07-10 (second pass), glow_source can ALSO carry a second "
        "entry (opportunity_type: external_empower) for an unrelated buff "
        "that empowers this ability - see glow_source.schema.json."
    ),
    "region_type": "icon",
    "trigger": "Action Usable (spell), ready/cooldown pair, disjunctive:any - paired with a required glow_source (buff_uptime) for the ability's own resulting buff",
    "type": "object",
    "required": ["name", "spell_id", "glow_source", "x", "y"],
    "properties": {
        "name": {"type": "string", "description": "Aura id/label."},
        "spell_id": {
            "type": ["string", "integer"],
            "description": "The spendable ABILITY's own spell ID (the thing you press) - distinct from glow_source's spell_id, which is the resulting BUFF it grants. Real confirmed example: Tormented Souls the ability is 500483; the buff it applies to self is 500481.",
        },
        "x": {"type": "number"},
        "y": {"type": "number"},
        "width": {"type": "number", "default": 40},
        "height": {"type": "number", "default": 30},
        "accent_color": {
            "type": "array",
            "default": [1, 1, 1, 1],
            "description": "subborder's color AND the glowexternal border-glow color (via glow_source's own accent_color reuse) - class accent (theme.json's accent_rgba) recommended, same convention as cooldown_tracker_icon.",
        },
        "glow_source": {
            "$ref": "glow_source.schema.json",
            "description": (
                "REQUIRED here (unlike cooldown_tracker_icon, where it's "
                "optional) - at least one entry, opportunity_type "
                "'buff_uptime', spell_id = the buff this ability grants "
                "to the player on use. This is the 'buff timer' half of "
                "the capability; the Action Usable pair above is the "
                "'spender' half. Optionally a second entry (opportunity_"
                "type 'external_empower') for an unrelated buff that "
                "empowers this ability - confirmed real via Tormented "
                "Souls v4's Soul Infusion texture overlay."
            ),
        },
    },
    "verified": (
        "CONFIRMED LIVE, 2026-07-10 - decoded Battlewrath's real, "
        "hand-built and live-tested 'Tormented Souls' export (v3, the "
        "version Battlewrath confirmed 'is now performing in-game how I "
        "expect') via weakaura_codec.py. Real captured trigger 1: {type: "
        "'spell', event: 'Action Usable', unit: 'player', use_spellName: "
        "true, spellName: 500483, use_genericShowOn: true, genericShowOn: "
        "'showOnReady', use_track: true}. Trigger 2: identical spellName, "
        "genericShowOn: 'showOnCooldown', use_inverse: true. Both also "
        "carried debuffType:'HELPFUL'/subeventPrefix/subeventSuffix - "
        "confirmed INERT leftover fields (same harmless aggregate-trigger-"
        "config-table phenomenon already documented for Power triggers in "
        "resource_threshold_aurabar.schema.json), deliberately not "
        "reproduced here. disjunctive:'any' and activeTriggerMode:-10 "
        "both present, matching this project's existing default pattern. "
        "Real conditions list (3 entries): trigger-2-show==1 -> "
        "desaturate:true (the fixed Condition baked into this template); "
        "trigger-3-show==1 -> glowexternal show (the buff_uptime "
        "mechanism, generated by the EXISTING glow_source filler code, "
        "unmodified) plus a bare no-op desaturate entry (harmless, same "
        "'off is inferred default' explanation Battlewrath gave directly - "
        "not a bug); trigger-3-show==0 -> glowexternal hide. Real "
        "subRegions: subbackground, a stack-count subtext ('%3.s', "
        "INNER_BOTTOMRIGHT, OUTLINE - baked into this template as a fixed "
        "field rather than the optional stack_counter_overlay fragment, "
        "since it's core to this capability's own defining lifecycle, not "
        "a bolt-on), and a subborder (border_edge 'Blizzard Dialog', "
        "border_color close to Reaper's own theme accent) - matching "
        "cooldown_tracker_icon's own already-formalized border language "
        "exactly. No subglow subRegion at all (confirmed correctly absent - "
        "glowexternal is frame-level, not subRegion-level, unlike "
        "proc_alert's sub.N.glow mechanism, which DOES need one). "
        "EXTENDED 2026-07-10 (second pass, same day): decoded a REAL v4 "
        "re-export of the same 'Tormented Souls' aura, now carrying a "
        "SECOND glow_source entry (external_empower, Soul Infusion "
        "803031) alongside the original buff_uptime one - confirming "
        "glow_source's multi-entry case works end to end on this exact "
        "template with zero further changes needed here. See "
        "glow_source.schema.json's own 'verified' field for the full "
        "external_empower trail."
    ),
}

RESOURCE_SPENDER_ICON_TEMPLATE = {
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
    "subRegions": [
        {"type": "subbackground"},
        {
            "type": "subtext",
            "text_text": "%3.s",
            "text_color": [1, 1, 1, 1],
            "text_font": "Friz Quadrata TT",
            "text_fontSize": 12,
            "text_fontType": "OUTLINE",
            "text_justify": "CENTER",
            "text_visible": True,
            "text_selfPoint": "AUTO",
            "anchor_point": "INNER_BOTTOMRIGHT",
            "anchorXOffset": 0,
            "anchorYOffset": 0,
            "text_shadowColor": [0, 0, 0, 1],
            "text_shadowXOffset": 0,
            "text_shadowYOffset": 0,
            "text_automaticWidth": "Auto",
            "text_fixedWidth": 64,
            "text_wordWrap": "WordWrap",
        },
        {
            "type": "subborder",
            "border_size": 2,
            "border_color": "{{accent_color}}",
            "border_visible": True,
            "border_edge": "Blizzard Dialog",
            "border_offset": 0,
        },
    ],
    "triggers": {
        "1": {
            "trigger": {
                "type": "spell",
                "event": "Action Usable",
                "unit": "player",
                "use_spellName": True,
                "spellName": "{{spell_id}}",
                "use_genericShowOn": True,
                "genericShowOn": "showOnReady",
                "use_track": True,
            },
            "untrigger": {},
        },
        "2": {
            "trigger": {
                "type": "spell",
                "event": "Action Usable",
                "unit": "player",
                "use_spellName": True,
                "spellName": "{{spell_id}}",
                "use_genericShowOn": True,
                "genericShowOn": "showOnCooldown",
                "use_inverse": True,
                "use_track": True,
            },
            "untrigger": {},
        },
        "activeTriggerMode": -10,
        "disjunctive": "any",
    },
    "conditions": [
        {
            "check": {"trigger": 2, "variable": "show", "value": 1},
            "changes": [{"property": "desaturate", "value": True}],
        },
    ],
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
    "verified": "Trigger type 'aura2' confirmed live-tested (Buffs/Utility static slots in Template_shadow.py). BuffTrigger2.lua registers 'aura2' (line 3798). FIELD-NAME BUG FIXED 2026-07-08: this template previously used 'spellIds'/'names', which are only ever read inside BuffTrigger2.lua's ConvertBuffTrigger2 (a one-time legacy-migration function for old pre-aura2 'buff' trigger data) - a natively-authored aura2 trigger never passes through it. The real fields the live matching code reads (confirmed directly, BuffTrigger2.lua lines 2598-2825/3722-3761) are 'useExactSpellId'+'auraspellids' (ID-based) or 'useName'+'auranames' (name-based). Fixed to 'auraspellids' (kept 'useExactSpellId', dropped the inert 'names' field). Found while building stance_loader_icon; caught before this template was ever used to build a real aura, so nothing shipped broken.",
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
                "auraspellids": ["{{spell_id}}"],
                "useExactSpellId": True,
                "ownOnly": "{{own_only}}",
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
        "show_when_missing": {
            "type": "boolean",
            "default": False,
            "description": (
                "OPTIONAL, added 2026-07-09 for Reaper's Soul Fragment "
                "(805077) - the first real consumer of this template. "
                "Battlewrath's own live-tested fix ('Maybe a second trigger "
                "when it's not active as an anti statement') for the "
                "footprint disappearing entirely whenever the buff is "
                "absent: adds a SECOND aura2 trigger on the same spell_id, "
                "matchesShowOn:'showOnMissing', combined with the real "
                "trigger 1 via disjunctive:'any' - the exact same "
                "'anti statement' mechanism already proven on "
                "backing_plate_icon's missing_state_option_names, just "
                "applied to THIS aura's own single trigger instead of a "
                "separate paired backing plate. Confirmed working live by "
                "Battlewrath ('Yes that fixed it') - one WA item, no "
                "backing_plate_aurabar pairing needed for footprint. NOTE: "
                "this does NOT solve permanent-tick visibility (a separate, "
                "since-abandoned problem) - a class_accent_tick_end style "
                "tick still vanishes during the missing state, confirmed by "
                "direct source read (RegionPrototype.lua's "
                "GetMinMaxProgress/UpdateProgressFromAuto zeroing out "
                "whenever the active trigger's progressType isn't 'timed'/"
                "'static' with real data - true for ANY trigger lacking a "
                "genuine duration, not something show_when_missing "
                "specifically causes). That problem is solved separately by "
                "Tiers/resources_base.py's divider_strip_slot, not by "
                "anything in this template - omit end_cap_color entirely "
                "on any bar using show_when_missing."
            ),
        },
        "show_stacks": {
            "type": "boolean",
            "default": False,
            "description": (
                "OPTIONAL, added 2026-07-09 alongside show_when_missing. "
                "Adds a '%s' stack-count subtext at INNER_RIGHT (opposite "
                "the permanent '%p' timer text at INNER_LEFT, baked into "
                "this template's own default subRegions below) - same "
                "state.stacks mechanism already proven on "
                "minion_presence_icon. Requested by Battlewrath for Soul "
                "Fragment ('Time remaining on soul fragment + stack "
                "count') but not yet present in the real hand-built "
                "prototype at the time it was captured - this formalizes "
                "the still-missing half."
            ),
        },
    },
    "verified": (
        "aurabar default fields from RegionTypes/AuraBar.lua; aura2 trigger "
        "shape shared with buff_uptime_icon above, including the same "
        "'spellIds'->'auraspellids' field-name fix - see that schema's "
        "'verified' field for the full trail. TIMER TEXT baked into this "
        "template's own default subRegions (added 2026-07-09, matching "
        "Battlewrath's real hand-built Soul Fragment prototype exactly, "
        "decoded via weakaura_codec.py): a '%p' subtext at INNER_LEFT, "
        "'timed' format, precision 1, threshold 60 - this template had "
        "never actually been used to build a real aura before Soul "
        "Fragment, so its previous bare 'subbackground'-only subRegions "
        "list was untested placeholder, not a deliberate design; the real "
        "capture's own timer-text shape is now the template default rather "
        "than an optional add-on, since a 'countdown bar' template with no "
        "countdown text defeats its own purpose."
    ),
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
            "text_automaticWidth": "Auto",
            "text_fixedWidth": 64,
            "text_wordWrap": "WordWrap",
            "text_text_format_p_format": "timed",
            "text_text_format_p_time_precision": 1,
            "text_text_format_p_time_format": 0,
            "text_text_format_p_time_dynamic_threshold": 60,
            "text_text_format_p_time_legacy_floor": False,
        },
    ],
    "triggers": {
        "1": {
            "trigger": {
                "type": "aura2",
                "event": "Health",
                "unit": "player",
                "debuffType": "HELPFUL",
                "auraspellids": ["{{spell_id}}"],
                "useExactSpellId": True,
                "ownOnly": True,
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
# 4b. health_range (aurabar) - Resources tier, Health-trigger sibling of
# resource_threshold_aurabar above
# ---------------------------------------------------------------------------

HEALTH_RANGE_AURABAR_SCHEMA = {
    "$id": "health_range_aurabar.schema.json",
    "opportunity_type": "health_range",
    "title": "Health range (aurabar, clamped percent-of-max window)",
    "description": "A unit-health bar clamped to a percent-of-max-health window (e.g. the TOP 50%-100%, empty at half health and full at max) rather than a plain 0-100% health bar - 'HP you can afford to lose/use', not total health remaining. Formalized 2026-07-09 as a primitive capability (Battlewrath: 'I'd formalize the health side as a capability... It comes between us as a primitive capability first' - before any class-implementer agent is allowed to consume it, per AGENT_ROLES.md's rule that classes must not invent local workarounds for missing mechanisms).",
    "region_type": "aurabar",
    "trigger": "Health",
    "type": "object",
    "required": ["name", "min_percent", "max_percent", "x", "y"],
    "properties": {
        "name": {"type": "string"},
        "min_percent": {
            "type": "string",
            "description": "The clamp's lower bound, as a string ENDING IN '%' (e.g. '50%') - NOT a plain number. This is the exact field WeakAuras' RegionPrototype.lua reads: a trailing '%' makes it store adjustedMinRelPercent = value/100, applied at render as adjustedMinRelPercent * total (max health) - true percent-of-max clamping. Omit the '%' and WeakAuras instead stores a literal absolute hit-point value, which on a real character (thousands of max HP) renders as pinned full or empty, not a percent window. This is not a hypothetical risk: Battlewrath's own real hand-built prototype ('Bloodmage_hp_resouece_50-100%', decoded 2026-07-07) shipped with plain '50'/'100' (no '%') and hit exactly this bug. Callers should use Tiers/resources_base.py's health_slot() builder, which takes plain numbers and appends the '%' itself so this mistake can't recur structurally - do not hand-construct this field's params dict directly.",
        },
        "max_percent": {
            "type": "string",
            "description": "The clamp's upper bound, same '%'-suffixed-string requirement as min_percent above (e.g. '100%').",
        },
        "bar_color": {
            "type": "array",
            "description": "OPTIONAL RGBA override for barColor - same non-placeholder-risk pattern as resource_threshold_aurabar's own bar_color (applied as a direct fill-time override in template_filler.py, which is NOT gated by template name, so it already covers this template with no code change). Omit to keep this template's default (a neutral red, not tied to any one class's theme).",
        },
        "x": {"type": "number"},
        "y": {"type": "number"},
        "width": {"type": "number", "default": 126},
        "height": {"type": "number", "default": 15},
    },
    "verified": "Formalized directly from two independent, corroborating sources: (1) direct source read of the real installed client's Interface/AddOns/WeakAuras/Prototypes.lua (~line 2273) confirming a native 'Health' unit-event trigger exists (type='unit', progressType='static', watches UNIT_HEALTH/UNIT_MAXHEALTH, exposes value/total/percenthealth/deficit/maxhealth) - the same trigger category/shape as the already-proven 'Power' trigger resource_threshold_aurabar uses, just no powertype field; and RegionTypes/RegionPrototype.lua (~line 368-796) confirming adjustedMin/adjustedMax/useAdjustededMin/useAdjustededMax's percent-suffix behavior. (2) A REAL live-built and live-tested WeakAuras export string Battlewrath pasted and confirmed in-game (2026-07-07): id 'Bloodmage_hp_resouece_50-100%', uid 'd4mA)3j847u', decoded via weakaura_codec.py - regionType='aurabar', trigger {type:'unit', event:'Health', unit:'player'}, useAdjustededMin/useAdjustededMax both true, subtext '%1.percenthealth'. The trigger dict in that real capture also carried several inert leftover fields (use_showAbsorb, use_absorbMode, use_maxhealth, subeventPrefix/Suffix, debuffType, names, spellIds, use_deficit, use_percenthealth, use_absorb) that don't affect a Health-event trigger's actual state fields - trimmed here the same way resource_threshold_aurabar's own 'verified' note trims Power's leftover fields, not something this template needs to reproduce. Percenthealth subtext format fields (text_text_format_1.percenthealth_*) are copied from that same real capture, not invented.",
}

HEALTH_RANGE_AURABAR_TEMPLATE = {
    "regionType": "aurabar",
    "width": "{{width}}",
    "height": "{{height}}",
    "orientation": "HORIZONTAL",
    "inverse": False,
    "barColor": [0.8, 0.1, 0.1, 1.0],
    "backgroundColor": [0.0, 0.0, 0.0, 0.5],
    "texture": "Blizzard",
    "textureSource": "LSM",
    "icon": False,
    "desaturate": False,
    "iconSource": -1,
    "displayIcon": "",
    "zoom": 0,
    "progressSource": [-1, ""],
    "adjustedMax": "{{max_percent}}", "adjustedMin": "{{min_percent}}",
    "useAdjustededMax": True, "useAdjustededMin": True,
    "spark": False,
    "subRegions": [
        {"type": "subbackground"},
        {
            "type": "subtext",
            "text_text": "%1.percenthealth",
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
            "text_text_format_1.percenthealth_format": "Number",
            "text_text_format_1.percenthealth_decimal_precision": 1,
            "text_text_format_1.percenthealth_pad": False,
            "text_text_format_1.percenthealth_pad_mode": "left",
            "text_text_format_1.percenthealth_pad_max": 8,
        },
    ],
    "triggers": {
        "1": {
            "trigger": {
                "type": "unit",
                "event": "Health",
                "unit": "player",
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
    "verified": "Confirmed by direct source read: BuffTrigger2.lua has a real matchesShowOn == 'showOnMissing' mode. Already load-bearing in Template_shadow.py's design (v0.13+ reserves the positional slots), though the actual trigger dict for showOnMissing specifically has not yet been captured from a real live-tested example in this project - same caveat as the glow_source conditions block. Also fixed the same 'spellIds'->'auraspellids' field-name bug as buff_uptime_icon (see that schema's 'verified' field) - the aura2 trigger here now uses the real matching fields too.",
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
                "auraspellids": ["{{spell_id}}"],
                "useExactSpellId": True,
                "ownOnly": True,
                "matchesShowOn": "showOnMissing",
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
        "total.' Confirmed directly in RegionTypes/AuraBar.lua's "
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
        "background_color": {
            "type": "array",
            "description": (
                "OPTIONAL, added 2026-07-09 for the new 'center-seam divider "
                "strip' use case (Necromancer's Mana/Runic Power + Reaper's "
                "Soul Fragment/Runic Power) - overrides backgroundColor "
                "directly (RGBA), the field this template's fill actually "
                "renders through per its own 'verified' note below (barColor "
                "never shows at 0% fill). Replaces class_accent_tick_end's "
                "role for any resource-tier bar pair, after live-testing "
                "found that mechanism's AtPercent tick placement depends on "
                "RegionPrototype.lua's GetMinMaxProgress(), which returns a "
                "zero range (and hides the tick) whenever the CURRENTLY "
                "ACTIVE trigger's own progressType isn't 'timed'/'static' "
                "with real data - true for Unit Characteristics (this "
                "template's own always-true trigger, which never sets "
                "progressType at all) and for an aura2 'missing' state alike "
                "(BuffTrigger2.lua's no-match branch sets progressType=nil). "
                "A plain instance of THIS template (already proven, no new "
                "mechanism) sidesteps that dependency entirely - it never "
                "computes a percentage against anything, so there's nothing "
                "to zero out. Omit to keep the original default "
                "backgroundColor=[0,0,0,0.5] dim-plate look."
            ),
        },
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

BACKING_PLATE_ICON_SCHEMA = {
    "$id": "backing_plate_icon.schema.json",
    "opportunity_type": "backing_plate",
    "title": "Backing plate (icon, always shown)",
    "description": (
        "An always-visible placeholder that sits BEHIND a trigger-gated "
        "icon (e.g. stance_loader_icon) at the exact same position/size, "
        "so the slot's footprint stays visible even while the real icon "
        "has no active option (e.g. no stance/ward currently up). Added "
        "2026-07-08, per Battlewrath's direct bug report on the real "
        "Undead Stance/Ward active build: 'they violate the owned "
        "footprint when not active.' Icon-region counterpart of "
        "backing_plate_aurabar - same mechanism (a separate, always-true-"
        "triggered element, not a modification of the real icon's own "
        "trigger/condition logic), same reasoning Battlewrath already "
        "gave for the aurabar version: 'the backing entity is the fix "
        "here... rather than over complicate the auras.' "
        "REVISED 2026-07-08 (same day, second pass) - the original plain-"
        "dim-square version (no fallback_icon) was live-tested and "
        "reported as failing: 'The backing plate did fail however. As it "
        "has no icon.' Battlewrath's own proposed fix: 'add a additional "
        "display, of one of the icons/spells... No boarder, but "
        "desaturated to show it is missing per stance.' Added the "
        "optional fallback_icon param below to do exactly that - a real "
        "spell icon, desaturated, no border, instead of a blank colored "
        "plate. fallback_icon omitted keeps the original blank-plate "
        "behavior (kept for any future case with no representative icon "
        "available). "
        "REVISED AGAIN 2026-07-08 (third pass, same day) - Battlewrath "
        "hand-edited the real Undead Stance Backing instance in-game "
        "(pasted back and decoded) with a BETTER mechanism for exactly "
        "the case fallback_icon couldn't cover: no confirmed spell ID at "
        "all. Own words: 'It is basically an anti statement. If neither "
        "of those auras are present, then show the desaturated version.' "
        "Formalized below as the optional missing_state_option_names "
        "param - an aura2 showOnMissing trigger using the SAME names as "
        "the paired stance_loader_icon's option_names, whose icon "
        "WeakAuras resolves live BY NAME in-game (no spellId needed at "
        "all, unlike fallback_icon), combined via a Condition that "
        "switches iconSource to that trigger's own number. Net visible "
        "behavior differs from the base 'always shown' contract: with "
        "this param, the element is visible ONLY while no option is "
        "active (the paired real icon covers the address the rest of the "
        "time, so the footprint is never actually lost) - a deliberate "
        "trade confirmed correct by Battlewrath's own real edit, not an "
        "oversight. fallback_icon and missing_state_option_names are "
        "alternative mechanisms for the same problem - prefer "
        "missing_state_option_names when no real spell ID/icon data "
        "exists (as for Undead Stance); fallback_icon remains valid where "
        "a real ID is already confirmed (as for Ward active)."
    ),
    "region_type": "icon",
    "trigger": "Unit Characteristics",
    "type": "object",
    "required": ["name", "x", "y"],
    "properties": {
        "name": {"type": "string"},
        "x": {"type": "number"},
        "y": {"type": "number"},
        "width": {"type": "number", "default": 30},
        "height": {"type": "number", "default": 20},
        "color": {
            "type": "array",
            "default": [1, 1, 1, 0.35],
            "description": (
                "Optional RGBA tint override. Added 2026-07-08 (third "
                "pass) since Battlewrath's real missing_state_option_names "
                "edit re-tinted this to a muted grey ([0.357, 0.357, "
                "0.357, 0.72]) to suit a real (desaturated) icon showing "
                "through, rather than the plain-blank-square default's "
                "dimmer white ([1,1,1,0.35])."
            ),
        },
        "fallback_icon": {
            "type": ["string", "integer", "null"],
            "default": None,
            "description": (
                "Optional. A spell ID (resolved to that spell's real icon "
                "via GetSpellInfo) OR a raw texture path - either works, "
                "per RegionTypes/RegionPrototype.lua's "
                "SetTextureOrSpellTexture ('local spellID = tonumber(path); "
                "if spellID then ... GetSpellInfo(spellID) ... else "
                "texture:SetTexture(path) end'). When supplied: iconSource "
                "is set to 0 (manual, RegionTypes/Icon.lua's UpdateIcon "
                "'elseif self.iconSource == 0 then iconPath = "
                "self.displayIcon'), icon:true, desaturate:true, no "
                "subborder - a real icon, grayed out, no color-coded "
                "border (that's reserved for the real active state on the "
                "icon on top). When omitted, falls back to the original "
                "icon:false blank dim-square plate. See "
                "missing_state_option_names for a mechanism that needs no "
                "spell ID at all - prefer that when no real ID is known."
            ),
        },
        "missing_state_option_names": {
            "type": "array",
            "items": {"type": "string"},
            "minItems": 2,
            "default": None,
            "description": (
                "Optional. Added 2026-07-08 (third pass), formalizing "
                "Battlewrath's own real fix for Undead Stance Backing "
                "(no confirmed spellId available for any of its 3 "
                "options). Same exact name list as the paired "
                "stance_loader_icon's option_names. Adds a second trigger "
                "(aura2, matchesShowOn:'showOnMissing', useName:true, "
                "ownOnly:true - fires 'show' only when NONE of the named "
                "auras are present) and a Condition that flips iconSource "
                "to that trigger's own number when it's active - "
                "WeakArua's aura2 trigger resolves an icon for the named "
                "spell(s) live in-game even in the 'missing' state, no "
                "spellId needed on our side at all. Net effect: this "
                "element only renders (a desaturated icon, resolved by "
                "name) while none of the options are active; the real "
                "stance_loader_icon on top covers the address the rest "
                "of the time. desaturate is forced true whenever this "
                "param is set (matches the real captured value)."
            ),
        },
    },
    "verified": (
        "Trigger identical to backing_plate_aurabar's own (Unit "
        "Characteristics, unit=player, unconditionally true - confirmed "
        "in Prototypes.lua line 1622+). frameStrata=2 (BACKGROUND, same "
        "enum confirmed in backing_plate_aurabar's own note) so it "
        "renders behind the real stance_loader_icon on top, which stays "
        "at the default frameStrata=1 (Inherited). fallback_icon's "
        "iconSource=0/displayIcon mechanism confirmed by DIRECT SOURCE "
        "READ of this project's own installed WeakAuras build "
        "(RegionTypes/Icon.lua's UpdateIcon function, lines ~551-566: "
        "iconSource==-1 -> self.state.icon (trigger-provided, the normal "
        "path every other icon template uses), iconSource==0 -> "
        "self.displayIcon (manual, this fragment's new path), any other "
        "value -> a specific trigger number's own icon). displayIcon's "
        "spell-ID-or-texture-path duality confirmed the same way, "
        "RegionPrototype.lua's SetTextureOrSpellTexture. fallback_icon "
        "itself still not independently live-tested in-game. "
        "missing_state_option_names' entire mechanism IS CONFIRMED LIVE "
        "(2026-07-08, third pass) - Battlewrath built and pasted back a "
        "real, hand-edited Undead Stance Backing instance using exactly "
        "this shape (decoded via weakaura_codec.py): trigger 2 = {type: "
        "'aura2', unit: 'player', auranames: [3 option names], useName: "
        "true, matchesShowOn: 'showOnMissing', ownOnly: true, "
        "debuffType: 'HELPFUL'} - notably NO 'event'/subeventPrefix/"
        "subeventSuffix keys at all (unlike this project's other aura2 "
        "triggers, e.g. stance_loader_icon's own - those fields are "
        "evidently not required for a bare showOnMissing presence check); "
        "conditions: [{check: {trigger: 2, variable: 'show', value: 1}, "
        "changes: [{property: 'iconSource', value: 2}]}]; no "
        "'disjunctive' key set at all, meaning the default 'all' (AND) "
        "combination applies (WeakAuras.lua line 3109) - trigger 1 "
        "(always true) AND trigger 2 (true only while missing) together "
        "mean the whole element is visible only in the missing state, "
        "exactly matching Battlewrath's own description ('anti "
        "statement... if neither of those auras are present, show the "
        "desaturated version'). desaturate was true and icon/iconSource "
        "were left at their base false/-1 in the exported static data "
        "(the iconSource:2 override only applies at runtime, dynamically, "
        "via the Condition) - matched exactly in this fragment's "
        "template_filler.py implementation."
    ),
}

BACKING_PLATE_ICON_TEMPLATE = {
    "regionType": "icon",
    "width": "{{width}}",
    "height": "{{height}}",
    "color": [1, 1, 1, 0.35],
    "desaturate": False,
    "iconSource": -1,
    "displayIcon": "",
    "icon": False,
    "cooldown": False,
    "cooldownEdge": False,
    "inverse": False,
    "zoom": 0,
    "keepAspectRatio": False,
    "frameStrata": 2,
    "progressSource": [-1, ""],
    "adjustedMax": "", "adjustedMin": "",
    "useAdjustededMax": False, "useAdjustededMin": False,
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
    "verified": "SubRegionTypes/Tick.lua read directly. tick_placement_mode='AtPercent' resolves 'minValue + tick_placements[i]*valueRange/100' against the bar's live GetMinMaxProgress() (UpdateTickPlacementOne, ~line 272) - placement 100 always lands at the bar's own current true max, independent of any other element (confirmed: the width scaled against is self.parentMajorSize, from self.parent.bar:GetRealSize(), where self.parent is THIS aurabar - no shared reference with a backing plate or any sibling element). FIELD-PARITY BUG, found and fixed 2026-07-06 (eleventh pass) via a real live-test round-trip: Battlewrath imported a fragment missing progressSources/automatic_length/tick_texture (present in Tick.lua's default()) and with tick_placements as a number; in-game the tick showed the stock default placement (50) until manually re-entered, and Battlewrath's own re-exported aura (decoded via weakaura_codec.py) confirmed real WeakAuras stores tick_placements as a string once committed through its options UI. This fragment now matches Tick.lua's default() table field-for-field, with tick_placements pre-set as the string '100' (not user-configurable - this fragment is always 'the end of the bar', unlike threshold_value).",
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
# stack_gain_flash_text (text region) - transient "+1"-style combat text,
# fires once on a genuine stack GAIN, not a persistent readout.
# ---------------------------------------------------------------------------
# Added 2026-07-06, per Battlewrath's direct request after confirming the
# "text" region type works in this pipeline (round-trip verified, then
# live-tested in-game with a static Life Force readout: renders, "%s"
# tracks the real stack count live, shows/hides correctly with the aura).
# Battlewrath: "I'd still like it to behave as you described as the
# combat text on gain only... I think combat like text for the classes
# will be useful for their own elements. Blood mage has a bottle they
# build up to 10 stacks into. So seeing per +1 flick in will be
# satisfying." Deliberately built generic/class-agnostic from the start
# (not hardcoded to Necromancer/Life Force) to match that stated intent -
# same registry pattern as every other fragment/template here.
STACK_GAIN_FLASH_TEXT_SCHEMA = {
    "$id": "stack_gain_flash_text.schema.json",
    "opportunity_type": "stack_gain_flash",
    "title": "Stack-gain flash (text, momentary)",
    "description": (
        "A standalone text-region aura that appears briefly ONLY when a "
        "tracked stacking aura's count goes UP (never on removal, never a "
        "persistent readout), then auto-reverts - a 'combat text' style "
        "'+1' flick-in, not a status display. Distinct from a "
        "buff_uptime_icon/aurabar's '%s' readout (this project's already-"
        "confirmed-working static approach, live-tested on Life Force "
        "2026-07-06) - that shows the CURRENT count continuously; this "
        "shows only the MOMENT of a gain, then disappears, even while the "
        "underlying stack is still present."
    ),
    "region_type": "text",
    "trigger": "Combat Log (SPELL_AURA_APPLIED_DOSE)",
    "type": "object",
    "required": ["name", "spell_id", "x", "y"],
    "properties": {
        "name": {
            "type": "string",
            "description": "Must match the tracked aura's real in-game display name exactly - used for name-based Combat Log filtering (see 'verified' field), same rank-safety reasoning as press_wash_effect.",
        },
        "spell_id": {
            "type": ["string", "integer"],
            "description": "The stacking aura's spell ID - documentation/reference only (e.g. Life Force: Visual, 525004). The actual trigger filters by name, not this ID directly - see 'verified'.",
        },
        "x": {"type": "number"},
        "y": {"type": "number"},
        "display_text": {
            "type": "string",
            "default": "+1",
            "description": "What flashes on a gain. Defaults to a fixed '+1', matching Battlewrath's own stated goal ('seeing per +1 flick in') and deliberately NOT the live new total - see 'verified' for why the live total isn't wired up yet (no confirmed dynamic-text token exists for a Combat Log DOSE event's 'amount' field, unlike aura2's confirmed-working '%s'). Override this per-ability if a gain is ever not exactly +1 (e.g. a spell that can grant 2+ stacks in one event).",
        },
        "duration": {
            "type": "number",
            "default": 1.0,
            "description": "Seconds the flash stays visible before auto-reverting - same native timedrequired mechanism already confirmed working for press_wash (GenericTrigger.lua's automaticAutoHide), just a longer default than press_wash's 0.3s since this needs to be readable as text, not just a color cue.",
        },
        "color": {
            "type": "array",
            "default": [1, 1, 1, 1],
            "description": "Text color - defaults to plain white; pass a class's accent_rgba for a class-tinted flash if wanted.",
        },
        "font_size": {"type": "integer", "default": 20},
    },
    "verified": (
        "Region type 'text' and its full default() field set confirmed "
        "TWO ways, not just read: (1) mechanically, via a new sibling "
        "harness (wa_lua_verify/harness_regiontype.lua, extending the "
        "existing SubRegionType harness's proven technique to "
        "Private.RegisterRegionType calls) run against the real, "
        "unmodified RegionTypes/Text.lua under real Lua 5.1.5 - output "
        "matched a direct source read exactly, no missing fields; (2) "
        "live, in-game: a standalone test aura (regionType 'text', aura2 "
        "trigger on Life Force 525004, displayText '%s') was built, "
        "round-trip verified, and pasted in-game by Battlewrath - "
        "confirmed rendering correctly, '%s' tracking the real live "
        "stack count, and showing/hiding correctly with the aura's own "
        "presence. That test also caught a real mistake in the first "
        "build: debuffType was wrongly set to 'HELPFUL' (copied verbatim "
        "from buff_uptime_icon's actual-buff pattern) when Life Force is "
        "a debuff - Battlewrath's real re-exported aura showed the "
        "correct 'HARMFUL' value, confirming the fix. "
        "SPELL_AURA_APPLIED_DOSE confirmed as a real, distinct Combat Log "
        "subevent (BuffTrigger2.lua lines 3432/3607, Types.lua line 1409, "
        "Prototypes.lua's subeventHeader enable-condition line 3438 "
        "explicitly checks for 'DOSE') - fires specifically when a "
        "stacking aura's count INCREASES, distinct from plain "
        "SPELL_AURA_APPLIED (first application) and SPELL_AURA_REMOVED_"
        "DOSE (a decrease). Same Combat Log trigger family already "
        "proven working for press_wash_effect - 'timedrequired' "
        "category, native automaticAutoHide, no custom Lua or manual "
        "revert Condition needed - just a different subeventSuffix and "
        "regionType 'text' instead of 'icon'. "
        "OPEN, NOT YET RESOLVED: whether a live/dynamic new-total display "
        "is possible here at all. Prototypes.lua confirms a generic "
        "'amount' field exists on combat log triggers (line 3563), likely "
        "populated from the DOSE event's own extra arg (the new stack "
        "count in real WoW's COMBAT_LOG_EVENT_UNFILTERED payload) - but "
        "WeakAuras.lua's Private.dynamic_texts table (the source of every "
        "working '%'-style text token) only defines p/t/n/i/s (progress/ "
        "duration/name/icon/stacks) - no 'amount' token exists there, and "
        "whether a combatlog trigger's 'amount' field ever populates "
        "state.stacks (so '%s' would resolve to it the way aura2's own "
        "stacks do) is NOT confirmed. Deliberately NOT guessed at here - "
        "shipped with a fixed 'display_text' default ('+1') instead, "
        "which directly satisfies Battlewrath's own stated ask without "
        "depending on this unresolved mechanism. Revisit only if a live "
        "dynamic total is specifically wanted later - would need its own "
        "source/live-test pass, same as everything else in this file."
    ),
}

STACK_GAIN_FLASH_TEXT_TEMPLATE = {
    "regionType": "text",
    "displayText": "{{display_text}}",
    "outline": "OUTLINE",
    "color": "{{color}}",
    "justify": "CENTER",
    "selfPoint": "CENTER",
    "anchorPoint": "CENTER",
    "anchorFrameType": "SCREEN",
    "font": "Friz Quadrata TT",
    "fontSize": "{{font_size}}",
    "frameStrata": 1,
    "customTextUpdate": "event",
    "automaticWidth": "Auto",
    "fixedWidth": 200,
    "wordWrap": "WordWrap",
    "shadowColor": [0, 0, 0, 1],
    "shadowXOffset": 1,
    "shadowYOffset": -1,
    "subRegions": [{"type": "subbackground"}],
    "triggers": {
        "1": {
            "trigger": {
                "type": "combatlog",
                "event": "Combat Log",
                "subeventPrefix": "SPELL",
                "subeventSuffix": "_AURA_APPLIED_DOSE",
                "use_sourceUnit": True,
                "sourceUnit": "player",
                "use_spellName": True,
                "spellName": ["{{name}}"],
                "use_spellId": False,
                "duration": "{{duration}}",
                "use_duration": True,
            },
            "untrigger": {},
        },
        "activeTriggerMode": -10,
    },
}

# ---------------------------------------------------------------------------
# stack_delta_flash_text (text region, Custom/stateupdate trigger) - a
# transient "+N<suffix>" flash reporting the POSITIVE delta between a
# tracked aura's last-seen and current stack count, computed live in Lua.
# ---------------------------------------------------------------------------
# Added 2026-07-07, formalizing Necromancer's Life Force delta feature
# (Templates/CUSTOM_STATEUPDATE_TRIGGER.md has the full research/build/
# live-test trail) into a generic, class-agnostic capability, per
# Battlewrath: "Having it as a specific capability is preferred."
#
# Distinct from stack_gain_flash_text above - that one is a wizard Combat
# Log trigger (SPELL_AURA_APPLIED_DOSE), which THREE separate live tests
# confirmed does not reliably fire for Necromancer's Life Force debuff
# (name-based, ID-based, and no-unit-filter variants all failed - see
# stack_gain_flash_text's own "verified" field and slot_assignment.md's
# 2026-07-06/07 change-log entry). stack_gain_flash_text is kept, not
# deleted - it may still be correct for some other class's ability that
# genuinely uses standard aura-stack combat log events. This template is
# the proven, working alternative: instead of waiting for a specific
# combat-log event, it re-reads the tracked aura's CURRENT stack count
# every time the player's auras change (UNIT_AURA:player) and computes
# the gain itself in Lua, live-confirmed working end to end on Life
# Force (525004) on 2026-07-07 ("It works fully as expected on our end").
STACK_DELTA_FLASH_TEXT_SCHEMA = {
    "$id": "stack_delta_flash_text.schema.json",
    "opportunity_type": "stack_delta_flash",
    "title": "Stack-delta flash (text, Custom/stateupdate trigger)",
    "description": (
        "A standalone text-region aura that flashes '+N<suffix>' whenever "
        "a tracked aura's stack count goes UP, where N is the actual "
        "delta between the last-seen and current count (not a fixed "
        "'+1') - computed live in Lua via a Custom (stateupdate) trigger "
        "that polls UnitAura() on every UNIT_AURA:player event, rather "
        "than waiting for a specific Combat Log subevent. Never fires on "
        "a decrease. Matches Battlewrath's exact spec: 1->3 = +2, "
        "2->5 = +3, decreases produce nothing."
    ),
    "region_type": "text",
    "trigger": "Custom (stateupdate) - polls UnitAura(unit, index, aura_filter) each UNIT_AURA:player event",
    "type": "object",
    "required": ["name", "spell_id", "aura_filter", "x", "y"],
    "properties": {
        "name": {
            "type": "string",
            "description": "Aura id/label only - the Lua matches purely by spell_id, not by name.",
        },
        "spell_id": {
            "type": ["string", "integer"],
            "description": "The tracked stacking aura's real spell ID (e.g. Life Force: Visual, 525004) - embedded directly into the Lua's UnitAura scan.",
        },
        "aura_filter": {
            "type": "string",
            "enum": ["HELPFUL", "HARMFUL"],
            "description": "Passed straight to UnitAura(unit, index, filter) - HARMFUL for a debuff (Life Force), HELPFUL for a buff (e.g. a future Blood Mage bottle-stack buff). Required - deliberately not defaulted, since guessing wrong here would silently never match anything.",
        },
        "x": {"type": "number"},
        "y": {"type": "number"},
        "label_suffix": {
            "type": "string",
            "default": "",
            "description": "Appended after the numeric delta, e.g. ' LF' for Life Force ('+2 LF'). Defaults to nothing.",
        },
        "duration": {
            "type": "number",
            "default": 1.5,
            "description": "Seconds the flash stays visible before auto-reverting, via the same native autoHide/expirationTime mechanism every timed element in this project already relies on (WeakAuras.lua's startStopTimers, confirmed generic to any state with these fields set, not trigger-type-specific).",
        },
        "font_size": {"type": "integer", "default": 20},
        "font": {
            "type": "string",
            "default": "Friz Quadrata TT",
            "description": "LibSharedMedia font name. Added 2026-07-08 after Battlewrath's real in-game edit of the Life Force instance changed font to 'MoK' (plus font_size 20->13) - previously hardcoded in the template, unreachable as a param.",
        },
        "color": {
            "type": "array",
            "default": [1, 1, 1, 1],
            "description": "Text color - defaults to plain white; pass a class's accent_rgba for a class-tinted flash if wanted.",
        },
    },
    "verified": (
        "Full mechanism source-verified before building (Templates/"
        "CUSTOM_STATEUPDATE_TRIGGER.md has the complete trail) and now "
        "LIVE-TEST CONFIRMED WORKING, 2026-07-07, across two real builds: "
        "v1 fired correctly on the very first live test ('That works as "
        "expected first time. :D'). v1 also surfaced a real bug, "
        "diagnosed by tracing GenericTrigger.lua/WeakAuras.lua directly "
        "rather than guessing again: the 'no new gain' branch explicitly "
        "wrote state.show=false on every UNIT_AURA tick (which fires "
        "constantly for reasons unrelated to the tracked aura, e.g. any "
        "other buff/debuff changing in combat), while returning false to "
        "suppress WeakAuras' own redraw signal (RunTriggerFunc, "
        "GenericTrigger.lua ~line 662: 'returnValue or (returnValue ~= "
        "false and allStates:IsChanged())' - an explicit false return "
        "short-circuits this entirely). That silently stamped show=false "
        "into the state without ever calling Private.UpdatedTriggerState "
        "(the function that actually invokes startStopTimers, WeakAuras."
        "lua ~line 4728, gated on state.changed) - so by the time the "
        "LEGITIMATE 1.5s auto-hide timer (scheduled on the original gain "
        "tick) fired, it found state.show already false and no-opped "
        "(startStopTimers' own guard: 'if not state.show or not state."
        "autoHide then stopAutoHideTimer(...); return end') instead of "
        "actively hiding - so the last rendered frame never got told to "
        "update, and the flash appeared stuck. Reported symptom matched "
        "exactly: fades correctly at the tracked aura's extremes (0 or "
        "cap, where there's typically a quiet moment with no unrelated "
        "UNIT_AURA churn before the timer fires), sticks in the middle "
        "(where churn is common). FIXED in v2 (this template's shipped "
        "Lua): the 'no new gain' branch now ONLY persists the lastCount "
        "bookkeeping value when it actually changes, and never touches "
        "show/autoHide/expirationTime itself - the auto-hide timer is "
        "left as the SOLE owner of visibility. v2 CONFIRMED WORKING, "
        "2026-07-07 ('It works fully as expected on our end'). "
        "SEPARATELY NOTED, not a bug: Battlewrath observed the server "
        "recalculates a resource like Life Force on summon by draining "
        "the ENTIRE current amount to 0 first, then refunding what's "
        "owed (e.g. a 1-cost summon with 3 banked drains to 0, then "
        "refunds 2) - this template correctly reports no flash on the "
        "drain (a decrease, by design) followed by a real '+2' flash on "
        "the refund, accurately reflecting the real underlying data even "
        "though a player might semantically expect '-1' - a server "
        "implementation detail, not something to fix here. "
        "SCOPING CHOICE, not yet generalized: 'player' is hardcoded as "
        "the scanned/watched unit (both in UnitAura's first arg and the "
        "events string) rather than exposed as a param - every real use "
        "case discussed so far (Life Force, a hypothetical Blood Mage "
        "bottle-stack buff) is a unit tracking its OWN stacking aura on "
        "itself. Revisit only if a genuine cross-unit case (e.g. "
        "tracking a pet's own stack count) is actually wanted. "
        "IMPLEMENTATION NOTE: the Lua 'custom' field embeds several "
        "params INSIDE one long function-literal string, which "
        "template_filler.py's generic {{}} substitution (whole-string-"
        "only regex) can't reach - filled via a dedicated Python "
        ".format() pass in template_filler.py instead, kept deliberately "
        "separate from the {{}} mechanism to avoid the two colliding "
        "(every literal Lua table constructor in the template below is "
        "doubled to {{ }} for exactly this reason)."
    ),
}

STACK_DELTA_FLASH_TEXT_LUA_TEMPLATE = """function(allstates, event, ...)
  local count, icon = 0, nil
  for i = 1, 40 do
    local name, _, ic, stacks, _, _, _, _, _, _, spellId = UnitAura("player", i, "{aura_filter}")
    if not name then break end
    if spellId == {spell_id} then
      count, icon = stacks or 1, ic
      break
    end
  end
  local lastCount = allstates:Get("", "lastCount") or 0
  if count > lastCount then
    allstates:Update("", {{
      show = true, name = "+" .. (count - lastCount) .. "{label_suffix}",
      icon = icon, progressType = "timed",
      expirationTime = GetTime() + {duration}, duration = {duration}, autoHide = true,
      lastCount = count,
    }})
    return true
  else
    if count ~= lastCount then
      allstates:Update("", {{ lastCount = count }})
    end
    return false
  end
end"""

STACK_DELTA_FLASH_TEXT_TEMPLATE = {
    "regionType": "text",
    "displayText": "%n",
    "outline": "OUTLINE",
    "color": "{{color}}",
    "justify": "CENTER",
    "selfPoint": "CENTER",
    "anchorPoint": "CENTER",
    "anchorFrameType": "SCREEN",
    "font": "{{font}}",
    "fontSize": "{{font_size}}",
    "frameStrata": 1,
    "customTextUpdate": "event",
    "automaticWidth": "Auto",
    "fixedWidth": 200,
    "wordWrap": "WordWrap",
    "shadowColor": [0, 0, 0, 1],
    "shadowXOffset": 1,
    "shadowYOffset": -1,
    "subRegions": [{"type": "subbackground"}],
    "triggers": {
        "1": {
            "trigger": {
                "type": "custom",
                "event": "Custom",
                "custom_type": "stateupdate",
                "events": "UNIT_AURA:player",
                "custom": STACK_DELTA_FLASH_TEXT_LUA_TEMPLATE,
            },
            "untrigger": {},
        },
        "activeTriggerMode": -10,
    },
}

# ---------------------------------------------------------------------------
# stance_loader_icon (icon, N mutually-exclusive aura2 triggers -> 1 icon)
# ---------------------------------------------------------------------------
# Added 2026-07-08, per Battlewrath's request to build the "1-of-3 stance"
# slot (Necromancer's Undead: Assault/Protect/Pacify - confirmed mutually
# exclusive directly from live trainer tooltip text: "Only 1 Undead Stance
# can be active at a time", Outputs/live_reference/necromancer_live_
# reference.json). Generalized as N-of-N (any count >= 2), not hardcoded to
# 3, since the underlying mechanism doesn't care how many mutually-exclusive
# options there are.
#
# Design settled through direct source-checking rather than the earlier
# Conditions-based icon-swap plan: confirmed (WeakAuras.lua lines 4744-4762)
# that activeTriggerMode=-10 ("first active" - already this project's
# standard default) picks whichever trigger is currently active and uses
# ITS OWN state for the region; and (RegionTypes/Icon.lua's UpdateIcon,
# iconSource==-1 branch) that the icon auto-resolves to self.state.icon -
# i.e. whichever trigger is active supplies its own icon automatically. So
# no Conditions block or manual icon-swapping is needed at all - one icon,
# N aura2 triggers OR'd together (disjunctive:"any", same reasoning as
# press_wash_effect - "first_active" mode alone doesn't make the icon VISIBLE
# across multiple triggers, only picks which one's state to show; the
# overall show/hide still needs at least one trigger active, and without
# disjunctive:"any" the default AND-combination would require every trigger
# active simultaneously, which can never happen for mutually-exclusive
# states).
#
# Matched by NAME, not spell ID: the live_reference capture has no spellId
# for these three (trainer-window data doesn't expose one), and they're
# single-rank abilities (no rank-multiplicity risk) - see BuffTrigger2.lua's
# real aura2 name-matching fields (useName/auranames), confirmed the same
# way as this session's spellIds->auraspellids fix above.
STANCE_LOADER_ICON_SCHEMA = {
    "$id": "stance_loader_icon.schema.json",
    "opportunity_type": "stance_loader",
    "title": "Stance loader (icon, N mutually-exclusive states -> 1 icon)",
    "description": (
        "One icon that shows whichever of N mutually-exclusive buffs is "
        "currently active (e.g. a class's stance/form set), auto-resolving "
        "its own icon art from whichever trigger is active - no manual icon "
        "path or Conditions-based swap needed."
    ),
    "region_type": "icon",
    "trigger": "Aura (N triggers, name-matched, disjunctive: any, activeTriggerMode: first_active)",
    "type": "object",
    "required": ["name", "option_names", "x", "y"],
    "properties": {
        "name": {"type": "string", "description": "Aura id/label."},
        "option_names": {
            "type": "array",
            "items": {"type": "string"},
            "minItems": 2,
            "description": "Exact real in-game display names of each mutually-exclusive option (e.g. ['Undead: Pacify', 'Undead: Protect', 'Undead: Assault']) - matched by name via aura2's useName/auranames, not spell ID.",
        },
        "x": {"type": "number"},
        "y": {"type": "number"},
        "width": {"type": "number", "default": 30},
        "height": {"type": "number", "default": 20},
        "border_colors": {
            "type": "array",
            "items": {"type": "array", "description": "RGBA, e.g. [0.55, 0.05, 0.05, 1.0]."},
            "description": (
                "Optional. One RGBA color per entry in option_names, same "
                "order/length - when supplied, a subborder is added and "
                "driven by a Condition per option (border shows that "
                "option's color while its own trigger is active). Added "
                "2026-07-08 per Battlewrath's real bug report: "
                "iconSource=-1 was resolving to the SAME icon art for all "
                "3 Undead Stance options in-game (the 3 real spells "
                "apparently share one icon texture), so the icon alone "
                "can't distinguish them - a border color is the fix, not "
                "a different icon-resolution mechanism. Left unset for "
                "options that don't need this (e.g. Ward active, not "
                "given colors yet)."
            ),
        },
    },
    "verified": (
        "Mutual exclusivity confirmed directly from live trainer tooltip "
        "text (Outputs/live_reference/necromancer_live_reference.json, "
        "source: 'trainer', verifiedLive: true): 'Only 1 Undead Stance can "
        "be active at a time.' iconSource=-1 auto-resolving to whichever "
        "trigger is active confirmed directly via RegionTypes/Icon.lua's "
        "UpdateIcon (iconSource==-1 branch reads self.state.icon) and "
        "WeakAuras.lua's activeTriggerMode='first_active' handling (lines "
        "4744-4762 - scans triggerState[id].triggers[i] for the first "
        "active one and uses ITS state). aura2 name-based matching fields "
        "(useName/auranames) confirmed the same way as the 'spellIds'->"
        "'auraspellids' fix on buff_uptime_icon/buff_uptime_aurabar/"
        "missing_buff_icon above (BuffTrigger2.lua lines 2598-2825/3722-"
        "3761) - built correctly from the start rather than copying the "
        "since-fixed wrong field names. Built and live-tested as a real "
        "instance (Undead Stance, Necro_animation_spec_UI_element) - "
        "Battlewrath's live-test feedback (2026-07-08): the icon itself "
        "renders the same texture for all 3 options, confirming iconSource "
        "auto-resolution alone isn't sufficient for this ability set. "
        "border_colors' 'sub.N.border_color' condition-property addressing "
        "is INFERRED BY ANALOGY from the independently-confirmed 'sub.N.glow' "
        "pattern (glow_source.schema.json) - subborder's border_color field "
        "is real (confirmed live via Test_Board_validation, see "
        "ICON_REGION_OPTIONS.md section 3), but driving it via a per-"
        "trigger Condition specifically has not yet been independently "
        "live-tested the way sub.N.glow has. Flag for a real live test "
        "before treating this as fully settled, same caveat class as "
        "glow_source's own still-unconfirmed second-trigger case."
    ),
}

STANCE_LOADER_ICON_TEMPLATE = {
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
    # "triggers" is intentionally empty here - the real per-option trigger
    # set is built entirely by template_filler.py's bespoke stance_loader_icon
    # block, since the number of triggers is dynamic (len(option_names)),
    # unlike every other template's fixed trigger count.
    "triggers": {},
}


# ---------------------------------------------------------------------------
# minion_presence_icon (icon, guardian-count aura2 - one child per minion
# TYPE, meant to sit inside a DynamicGroup so it re-flows)
# ---------------------------------------------------------------------------
# Added 2026-07-08, formalizing Battlewrath's real, hand-built "Minion
# tracker" DynamicGroup (decoded via weakaura_codec.py): a fixed row of
# per-minion-type icons (Abomination, Skeleton, and a third named "Crypt
# Fiend" in the real capture - Battlewrath's own correction, 2026-07-09:
# the real spell is "Crypt Keeper", spellId 800034), each independently
# shown/hidden by its own "guardian count" owner-buff aura2 trigger
# (Apply Area Aura: Pet Owner - see Necromancer/spell_index.md's own
# "Guardian count buff" writeup, confirmed live 2026-07-06/07 for
# Skeletal Warrior/Abomination). Battlewrath's own framing: "it helps
# show what you have summoned at any one time... not perfect counting...
# just insight."
#
# Built to match the "expected, normal function" first (Battlewrath,
# 2026-07-09) - i.e. plain aura2 useStacks + a %s stack-count subtext,
# exactly as the real capture has it - deliberately NOT yet fixing the
# known matchCount/bestMatch limitation (see 'verified' below); that's
# explicitly deferred as a "tailored item" for later, not an oversight.
MINION_PRESENCE_ICON_SCHEMA = {
    "$id": "minion_presence_icon.schema.json",
    "opportunity_type": "minion_presence",
    "title": "Minion presence (icon, guardian-count aura2 + stack subtext)",
    "description": (
        "Shows whether at least one active summon of a given minion TYPE "
        "is currently up, via the real 'guardian count' owner-buff "
        "mechanism (each active pet of a type applies its own instance of "
        "a matching aura onto the player - 'Apply Area Aura: Pet Owner'). "
        "Meant to be used as a slot inside a dynamicgroup layer (not a "
        "static group) so that minion types with no active summon simply "
        "aren't rendered, and the remaining active icons re-flow to close "
        "the gap - confirmed live via Battlewrath's own hand-built "
        "'Minion tracker' capture (grow: RIGHT, align: CENTER, space: 2)."
    ),
    "region_type": "icon",
    "trigger": "Aura (aura2, useStacks - see 'verified' for a known accuracy caveat)",
    "type": "object",
    "required": ["name", "guardian_aura_id", "x", "y"],
    "properties": {
        "name": {"type": "string", "description": "Aura id/label - the minion type's display name, e.g. 'Skeleton'."},
        "guardian_aura_id": {
            "type": ["string", "integer"],
            "description": (
                "The guardian-count owner-buff's own spell ID (NOT the "
                "summon-cast spell ID) - e.g. 805016 for Skeletal Warrior, "
                "805017 for Abomination, 800034 for Crypt Keeper. Matched "
                "by exact spell ID (useExactSpellId), same as buff_uptime_"
                "icon's own auraspellids field."
            ),
        },
        "x": {"type": "number"},
        "y": {"type": "number"},
        "width": {"type": "number", "default": 30},
        "height": {"type": "number", "default": 40},
    },
    "verified": (
        "CONFIRMED LIVE, 2026-07-08/09 - decoded Battlewrath's real "
        "'Minion tracker' export via weakaura_codec.py. Real per-child "
        "trigger shape: {type: 'aura2', event: 'Health', unit: 'player', "
        "debuffType: 'HELPFUL', auraspellids: [<id>], useExactSpellId: "
        "true, ownOnly: true, useStacks: true, subeventPrefix: 'SPELL', "
        "subeventSuffix: '_CAST_START'} - matches buff_uptime_icon's own "
        "aura2 shape exactly, plus useStacks:true. Each child also carries "
        "a '%s' stack-count subtext (INNER_BOTTOMRIGHT, OUTLINE) and an "
        "unused subglow (glow:false) in the real capture - both kept here "
        "for parity even though the subglow isn't wired to anything yet. "
        "KNOWN LIMITATION, confirmed by direct source read (BuffTrigger2."
        "lua, 2026-07-09), NOT fixed in this pass - Battlewrath's own "
        "diagnosis: each active pet of a type applies its OWN separate, "
        "non-stacking aura instance (distinct casters), not one aura "
        "incrementing a shared stack count - '3x1' not '1x3'. Confirmed "
        "directly: BuffTrigger2.lua's aura2 scanner picks one 'bestMatch' "
        "instance among however many separate instances match, and "
        "state.stacks (what '%s' reads) is bestMatch's OWN stack field - "
        "never a sum. So with 3 separate single-caster instances (each "
        "stacks=1), '%s' shows '1', not '3' - presence-accurate, count-"
        "inaccurate. WeakAuras DOES separately compute the true aggregate "
        "internally (state.matchCount / state.totalStacks, BuffTrigger2."
        "lua ~line 574), but there's no built-in dynamic-text token for it "
        "(Prototypes.lua's dynamic_texts only maps p/t/n/i/s) - a real "
        "fix would need a Custom text expression reading matchCount "
        "directly, not a stock format string. Deliberately deferred per "
        "Battlewrath's own call: 'let's build around the expected, normal "
        "function. Then add the tailored items later.' "
        "POSSIBLE FUTURE RE-EXPLORE, noted lightly 2026-07-10 (side-agent "
        "session, not acted on now): that same session independently "
        "confirmed 'sourceGUID'/'destGUID' are real, store=true fields on "
        "Combat Log triggers (direct read of Prototypes.lua). Since this "
        "limitation's root cause is aura2 collapsing several distinct "
        "same-type instances into one 'bestMatch,' a Combat Log-based "
        "trigger keyed off sourceGUID/destGUID could in principle "
        "disambiguate instances individually instead of relying on "
        "aura2's single-match behavior - a plausible path to a real fix, "
        "not a designed solution. Revisit only if this limitation actually "
        "becomes a blocker for a real class build, per the same 'expected, "
        "normal function first' deferral logic above."
    ),
}

MINION_PRESENCE_ICON_TEMPLATE = {
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
    "subRegions": [
        {"type": "subbackground"},
        {
            "type": "subtext",
            "text_text": "%s",
            "text_color": [1, 1, 1, 1],
            "text_font": "Friz Quadrata TT",
            "text_fontSize": 12,
            "text_fontType": "OUTLINE",
            "text_justify": "CENTER",
            "text_visible": True,
            "text_selfPoint": "AUTO",
            "anchor_point": "INNER_BOTTOMRIGHT",
            "anchorXOffset": 0,
            "anchorYOffset": 0,
            "text_shadowColor": [0, 0, 0, 1],
            "text_shadowXOffset": 0,
            "text_shadowYOffset": 0,
            "text_automaticWidth": "Auto",
            "text_fixedWidth": 64,
            "text_wordWrap": "WordWrap",
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
                "type": "aura2",
                "event": "Health",
                "unit": "player",
                "debuffType": "HELPFUL",
                "auraspellids": ["{{guardian_aura_id}}"],
                "useExactSpellId": True,
                "ownOnly": True,
                "useStacks": True,
                "subeventPrefix": "SPELL",
                "subeventSuffix": "_CAST_START",
            },
            "untrigger": {},
        },
        "activeTriggerMode": -10,
    },
}


# ---------------------------------------------------------------------------
# load_conditions - a UNIVERSAL optional fragment, applicable to ANY
# template (not $ref'd from individual schemas' properties the way
# glow_source/power_threshold/press_wash are, since every leaf aura already
# carries its own "load" dict via base_envelope() - see template_filler.py's
# own generic, template-name-unconditional handling block).
# ---------------------------------------------------------------------------
# Added 2026-07-08, per Battlewrath's real, hand-built example: the "LF
# Delta Test" (stack_delta_flash_text/Life Force) instance was edited
# in-game to require both "Player Class: Necromancer" and "In Combat", then
# pasted back and decoded. Battlewrath's own framing: "I imagine the whole
# pack will use the 'Must be on necromancer'. The in-combat will be more
# selective. Such as the proc tier. But this is a new class of action that
# a WA can adhere to... you should emulate to capture a broader view of
# things we can declare." - i.e. this is a NEW declarable axis (load
# conditions), general to the whole tool, not a one-off fix for one aura.
LOAD_CONDITIONS_SCHEMA = {
    "$id": "load_conditions.schema.json",
    "title": "Load conditions (universal fragment - applies to any template)",
    "description": (
        "WeakAuras' real 'Load' tab - conditions on WHETHER an aura is "
        "loaded at all (checked once on login/event, distinct from a "
        "trigger's show/hide, which runs continuously while loaded). "
        "Optional on every template, since 'load' is already part of every "
        "leaf aura's envelope (base_envelope()'s own class/size/spec "
        "placeholders). Only 'classes' and 'combat' are wired as params so "
        "far, backed by Battlewrath's own real captured example - the "
        "much larger full field catalog (see 'verified') exists in "
        "WeakAuras' own load_prototype and is documented here as a map of "
        "what else this project could declare later, not yet built."
    ),
    "type": "object",
    "properties": {
        "classes": {
            "type": "array",
            "items": {"type": "string"},
            "description": (
                "Player class name(s) required to load, e.g. "
                "['NECROMANCER'] - this server's class_types list is "
                "populated dynamically and includes Ascension's own "
                "custom classes alongside the 11 stock WoW classes "
                "(Types.lua line 1186, 'WeakAuras.class_types = {}', "
                "filled at runtime). Single-class case (len==1) is "
                "CONFIRMED LIVE (see 'verified'); multi-class case is "
                "inferred by analogy, not independently tested."
            ),
        },
        "combat": {
            "type": ["boolean", "null"],
            "default": None,
            "description": (
                "Tristate: true = must be IN combat, false = must NOT be "
                "in combat, omitted/null = ignored (no combat requirement "
                "at all). CONFIRMED LIVE for true (see 'verified') - "
                "false is inferred by analogy with WeakAuras' documented "
                "tristate convention (Prototypes.lua's load_prototype "
                "'combat' arg, type='tristate'), not independently tested."
            ),
        },
    },
    "verified": (
        "CONFIRMED LIVE, 2026-07-08 - Battlewrath hand-built a real "
        "load-conditioned instance (LF Delta Test: Necromancer class + In "
        "Combat) directly in-game and pasted back the export string, "
        "decoded via weakaura_codec.py. Real captured 'load' dict: "
        "{use_class: true, class: {single: 'NECROMANCER', multi: []}, "
        "spec: {multi: []}, use_combat: true, size: {multi: []}} - "
        "confirms (1) a multiselect-type load field ('class', "
        "Prototypes.lua's load_prototype 'class' arg, type='multiselect', "
        "values='class_types') is encoded as a companion 'use_class' gate "
        "boolean PLUS a nested {single, multi} value dict, matching this "
        "project's already-established WeakAuras multiselect pattern "
        "elsewhere; (2) a tristate-type load field ('combat', "
        "load_prototype's 'combat' arg, type='tristate') is encoded as A "
        "SINGLE 'use_combat' key carrying the tristate value directly (no "
        "companion value field at all - confirmed by its total absence "
        "from the real capture, which has only 'use_combat: true', never "
        "a separate 'combat: true'). "
        "FULL FIELD CATALOG (direct source read, Prototypes.lua's "
        "Private.load_prototype table, line 963+, NOT independently "
        "tested field-by-field beyond classes/combat above - catalogued "
        "for future extension, not guessed at): "
        "General (tristate unless noted): combat, never (toggle, always "
        "false - 'never load'), alive, encounter (DBM-based), pvpmode, "
        "manastorm, vehicle, vehicleUi, mounted. "
        "Player: class (multiselect, class_types - includes Ascension's "
        "custom classes), specialization (multiselect, "
        "specialization_types - ASCENSION'S OWN CUSTOM SPEC SYSTEM, "
        "SpecializationUtil.GetSpecializationInfo - directly relevant to "
        "a future per-spec Necromancer load condition, since Necromancer "
        "has multiple specs per CLASS_BEHAVIOR_PROFILES.md's '69 specs' "
        "framing), knowntalent (talent-type, Ascension's "
        "IsTalentKnownForLoad), mysticenchantactive/not_mysticenchantactive "
        "(Ascension's own 'Mystic Enchant' system), spellknown/"
        "not_spellknown, race (multiselect), faction (multiselect), level "
        "(number, supports a 2-entry AND range per multiEntry - i.e. a "
        "min/max band), role (multiselect, role_types), spec_position "
        "(multiselect, Ascension-specific), raid_role (multiselect), "
        "ingroup/groupSize/group_leader (party/raid composition), ruleset "
        "(multiselect, PvP ruleset). "
        "Location: zone/zoneId/subzone (string, supports comma-separated "
        "multi-entry with '-' negation), encounterid (DBM encounter IDs), "
        "size (multiselect, instance_types - solo/party/raid), difficulty "
        "(multiselect, difficulty_types). "
        "Equipment: itemequiped/not_itemequiped (item-type, supports OR "
        "multi-entry), itemtypeequipped (multiselect, weapon type). "
        "Encoding pattern for these other types (string/number/item) is "
        "NOT yet confirmed the way multiselect/tristate are above - "
        "would need its own real captured example before wiring as a "
        "param, per this project's evidenced-not-invented rule."
    ),
}


# ---------------------------------------------------------------------------
# Registry - drives both file generation and the filler's lookup
# ---------------------------------------------------------------------------

REGISTRY = {
    "cooldown_tracker_icon": (COOLDOWN_TRACKER_ICON_SCHEMA, COOLDOWN_TRACKER_ICON_TEMPLATE),
    "resource_spender_icon": (RESOURCE_SPENDER_ICON_SCHEMA, RESOURCE_SPENDER_ICON_TEMPLATE),
    "proc_alert_icon": (PROC_ALERT_ICON_SCHEMA, PROC_ALERT_ICON_TEMPLATE),
    "buff_uptime_icon": (BUFF_UPTIME_ICON_SCHEMA, BUFF_UPTIME_ICON_TEMPLATE),
    "buff_uptime_aurabar": (BUFF_UPTIME_AURABAR_SCHEMA, BUFF_UPTIME_AURABAR_TEMPLATE),
    "resource_threshold_aurabar": (RESOURCE_THRESHOLD_AURABAR_SCHEMA, RESOURCE_THRESHOLD_AURABAR_TEMPLATE),
    "health_range_aurabar": (HEALTH_RANGE_AURABAR_SCHEMA, HEALTH_RANGE_AURABAR_TEMPLATE),
    "missing_buff_icon": (MISSING_BUFF_ICON_SCHEMA, MISSING_BUFF_ICON_TEMPLATE),
    "enemy_cast_aurabar": (ENEMY_CAST_AURABAR_SCHEMA, ENEMY_CAST_AURABAR_TEMPLATE),
    "player_cast_aurabar": (PLAYER_CAST_AURABAR_SCHEMA, PLAYER_CAST_AURABAR_TEMPLATE),
    "swing_timer_aurabar": (SWING_TIMER_AURABAR_SCHEMA, SWING_TIMER_AURABAR_TEMPLATE),
    "backing_plate_aurabar": (BACKING_PLATE_AURABAR_SCHEMA, BACKING_PLATE_AURABAR_TEMPLATE),
    "backing_plate_icon": (BACKING_PLATE_ICON_SCHEMA, BACKING_PLATE_ICON_TEMPLATE),
    "pet_summon_countdown_icon": (PET_SUMMON_COUNTDOWN_ICON_SCHEMA, PET_SUMMON_COUNTDOWN_ICON_TEMPLATE),
    "stack_gain_flash_text": (STACK_GAIN_FLASH_TEXT_SCHEMA, STACK_GAIN_FLASH_TEXT_TEMPLATE),
    "stack_delta_flash_text": (STACK_DELTA_FLASH_TEXT_SCHEMA, STACK_DELTA_FLASH_TEXT_TEMPLATE),
    "stance_loader_icon": (STANCE_LOADER_ICON_SCHEMA, STANCE_LOADER_ICON_TEMPLATE),
    "minion_presence_icon": (MINION_PRESENCE_ICON_SCHEMA, MINION_PRESENCE_ICON_TEMPLATE),
}

FRAGMENTS = {
    "glow_source": GLOW_SOURCE_SCHEMA,
    "stack_counter_overlay": STACK_COUNTER_OVERLAY_SCHEMA,
    "class_accent_tick_end": CLASS_ACCENT_TICK_END_SCHEMA,
    "power_threshold_effect": POWER_THRESHOLD_EFFECT_SCHEMA,
    "press_wash_effect": PRESS_WASH_EFFECT_SCHEMA,
    "load_conditions": LOAD_CONDITIONS_SCHEMA,
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
