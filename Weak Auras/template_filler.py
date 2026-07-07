"""
Fills a phase-3 JSON template (Weak Auras/Templates/templates/*.template.json)
with real parameters (spell IDs, name, position) validated against its
paired schema (Weak Auras/Templates/schemas/*.schema.json), producing a
Python dict ready for weakaura_codec.py's encode_group_import_string /
encode_import_string.

Deliberately dependency-free (no `jsonschema` pip package) - consistent
with weakaura_codec.py's own "standalone, dependency-free" design. Schema
validation here is a plain required-field check, not full JSON Schema
semantics; the schema files are still real, valid JSON Schema-shaped
documents for the human/tooling reference value, just not run through a
validator library.

KNOWN JSON <-> Lua-table gotcha, same family as weakaura_codec.py's own
empty-array-vs-empty-map note: WeakAuras' real "triggers" dict is keyed by
INTEGER trigger index (1, 2, ...) alongside a literal STRING key
"activeTriggerMode" in the same dict (confirmed directly from
EXAMPLE_TEST_AURA). JSON cannot represent integer object keys, so the
template files use the string "1"/"2" - fill_template() converts any
purely-numeric string key inside "triggers" to a real Python int key
before handing back the final dict. Forgetting this step would silently
produce a dict that looks right when printed but fails the same way the
v0.9 controlledChildren bug did - encodes without error, then misbehaves
or is invisible in-game, per weakaura_codec.py's own debugging checklist.
"""
import copy
import json
import os
import re
import sys

_THIS_DIR = os.path.dirname(os.path.abspath(__file__))
TEMPLATES_ROOT = os.path.join(_THIS_DIR, "Templates")
sys.path.insert(0, TEMPLATES_ROOT)
from build_templates import REGISTRY, FRAGMENTS, FRAGMENT_TEMPLATES, base_envelope

_PLACEHOLDER_RE = re.compile(r"^\{\{(\w+)\}\}$")


def _load_pair(template_name):
    if template_name not in REGISTRY:
        raise KeyError(f"Unknown template '{template_name}'. Known: {sorted(REGISTRY)}")
    schema_path = os.path.join(TEMPLATES_ROOT, "schemas", f"{template_name}.schema.json")
    template_path = os.path.join(TEMPLATES_ROOT, "templates", f"{template_name}.template.json")
    with open(schema_path) as f:
        schema = json.load(f)
    with open(template_path) as f:
        template = json.load(f)
    return schema, template


def _validate_required(schema, params):
    missing = [field for field in schema.get("required", []) if field not in params]
    if missing:
        raise ValueError(
            f"Missing required param(s) for '{schema.get('$id')}': {missing}"
        )


def _substitute(node, params):
    """Recursively replace '{{key}}' string leaves with params[key]."""
    if isinstance(node, dict):
        return {k: _substitute(v, params) for k, v in node.items()}
    if isinstance(node, list):
        return [_substitute(v, params) for v in node]
    if isinstance(node, str):
        m = _PLACEHOLDER_RE.match(node)
        if m:
            key = m.group(1)
            return params.get(key, node)
        return node
    return node


def _intify_trigger_keys(triggers_dict):
    """Convert purely-numeric string keys ('1', '2') to real int keys,
    leaving non-numeric keys ('activeTriggerMode') untouched - see this
    module's docstring for why this specific dict needs it."""
    out = {}
    for k, v in triggers_dict.items():
        if isinstance(k, str) and k.isdigit():
            out[int(k)] = v
        else:
            out[k] = v
    return out


def fill_template(template_name, params, uid=None, generate_uid_fn=None):
    """
    template_name: one of REGISTRY's keys (e.g. "cooldown_tracker_icon").
    params: dict matching the template's schema (name, spell_id/x/y/... ,
            optionally 'glow_source': [{'opportunity_type':..., 'spell_id':...}],
            optionally 'stack_counter': {'enabled': True, ...},
            optionally 'power_threshold': {'powertype':..., 'cost':...,
            'cost_is_percent': bool, 'include_afford_glow': bool}).
    uid: pass an explicit uid, or supply generate_uid_fn (e.g.
         weakaura_codec.generate_unique_id) to have one generated -
         required per this project's own uid-collision incident (see
         weakaura_codec.py's debugging checklist item 1).
    Returns a plain dict, ready to hand to weakaura_codec's encode
    functions as one child aura.
    """
    schema, template = _load_pair(template_name)
    _validate_required(schema, params)

    if uid is None:
        if generate_uid_fn is None:
            raise ValueError(
                "fill_template needs either uid= or generate_uid_fn= "
                "(e.g. weakaura_codec.generate_unique_id) - never leave "
                "uid unset silently, per this project's real uid-collision "
                "incident (v0.9, see weakaura_codec.py's docstring)."
            )
        uid = generate_uid_fn()

    fill_params = dict(params)
    fill_params.setdefault("uid", uid)
    fill_params.setdefault("width", schema["properties"].get("width", {}).get("default"))
    fill_params.setdefault("height", schema["properties"].get("height", {}).get("default"))
    # Optional per this project's convention (width/height above) - only
    # meaningful for templates whose schema actually declares it (currently
    # cooldown_tracker_icon, added 2026-07-06 alongside power_threshold).
    if "accent_color" in schema["properties"]:
        fill_params.setdefault("accent_color", schema["properties"]["accent_color"].get("default"))
    # Same pattern, added 2026-07-08 alongside the new 'font' param on
    # stack_delta_flash_text/stack_gain_flash_text - font/font_size/color
    # are plain {{}}-substituted template leaves (not schema-required), so
    # without this an omitted param would silently strand the literal
    # "{{font}}"/"{{font_size}}"/"{{color}}" string in the built aura
    # instead of resolving to the schema's own stated default.
    #
    # 'own_only' ADDED 2026-07-09 - a real, previously-latent bug found the
    # first time buff_uptime_icon was ever actually used to build a real
    # aura (Razorice/Foul Mandate, Necromancer/inventory.py's new "Buff
    # Index" layer): BUFF_UPTIME_ICON_TEMPLATE's trigger has
    # "ownOnly": "{{own_only}}", but nothing ever defaulted it, so both
    # built children shipped with the literal, unresolved string
    # "{{own_only}}" in place of a real boolean - same failure class as the
    # 2026-07-06 threshold_value/font bugs (an optional, schema-defaulted
    # param with no corresponding fill_params.setdefault call). Caught by
    # inspecting the decoded real output before shipping, not live-tested
    # first.
    for _optional_field in ("font", "font_size", "color", "own_only"):
        if _optional_field in schema["properties"]:
            fill_params.setdefault(_optional_field, schema["properties"][_optional_field].get("default"))

    merged = {**base_envelope(), **template}
    result = _substitute(merged, fill_params)

    # Stack counter overlay (optional)
    stack_counter = params.get("stack_counter")
    if stack_counter and stack_counter.get("enabled"):
        overlay_params = {
            "font_size": stack_counter.get("font_size", 12),
            "anchor_point": stack_counter.get("anchor_point", "BOTTOMRIGHT"),
        }
        overlay = _substitute(copy.deepcopy(FRAGMENT_TEMPLATES["stack_counter_overlay"]), overlay_params)
        result.setdefault("subRegions", []).append(overlay)

    # Threshold tick marker (optional, resource_threshold_aurabar only) - FIXED
    # 2026-07-06 (later same day): this used to be baked unconditionally into
    # RESOURCE_THRESHOLD_AURABAR_TEMPLATE as a "{{threshold_value}}" string
    # placeholder, which was never substituted for either real built aura
    # (Mana, Runic Power - neither had a threshold requested), so both
    # shipped with a literal, broken tick_placements value. Moved here,
    # same append-only-if-present pattern as stack_counter/glow_source
    # above, so omitting threshold_value now correctly ships a plain bar
    # with no subtick at all.
    # Bar color override (optional, resource_threshold_aurabar) - added
    # 2026-07-06 (fourth revision): Mana and Runic Power share one
    # template but were given different in-game colors by Battlewrath
    # (Runic Power recolored, Mana left default) - a direct post-
    # substitution override, same non-placeholder pattern as
    # threshold_value below, so it can't strand an unresolved "{{...}}"
    # string the way a plain template placeholder would if a specific
    # fill omitted it.
    bar_color = params.get("bar_color")
    if bar_color is not None:
        result["barColor"] = list(bar_color)

    threshold_value = params.get("threshold_value")
    if threshold_value is not None:
        # FIXED 2026-07-06 (eleventh pass): this used to omit progressSources/
        # automatic_length/tick_texture (present in Tick.lua's own default()
        # table) and stored tick_placements as a number - the same defect
        # found and fixed on class_accent_tick_end below via a real live-test
        # round-trip (see that fragment's schema for the full trail). Never
        # actually live-tested itself (no threshold has been requested yet),
        # but fixed proactively now that the shared defect is known.
        tick_fragment = {
            "type": "subtick",
            "tick_visible": True,
            "tick_color": [1, 1, 1, 1],
            "tick_placement_mode": "AtValue",
            "tick_placements": [str(threshold_value)],
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
        result.setdefault("subRegions", []).append(tick_fragment)

    # Permanent end-cap marker (optional, resource_threshold_aurabar only) -
    # added 2026-07-06 (tenth pass), discussed with Battlewrath before
    # building per CLAUDE.md's working agreement. Distinct from
    # threshold_value above: uses tick_placement_mode="AtPercent" with
    # placements=["100"] (not "AtValue"), which SubRegionTypes/Tick.lua
    # resolves against the bar's live min/max every update - always the
    # bar's own current 100% edge, regardless of what max mana/RP actually
    # is. Fixes the reference-point ambiguity created once the backing
    # plate's darkness was matched to the real bars (ninth pass): Mana/
    # Runic Power now visually fuse with their adjacent backing plate into
    # one continuous strip at rest, so there was no longer a visible seam
    # marking the resource bar's own max extent.
    #
    # PROMOTED 2026-07-06 (eleventh pass) to a named, reusable FRAGMENT
    # (class_accent_tick_end, in build_templates.py/Templates/schemas
    # /Templates/templates) per Battlewrath: "make that tick a known
    # element ... a subtle design language through all the UI's" - not
    # hand-built inline here anymore. Also fixed the same live-tested
    # field-parity bug as threshold_value above: the first version shipped
    # without progressSources/automatic_length/tick_texture and with
    # tick_placements as a number, which showed up in-game as the tick
    # sitting at Tick.lua's own stock default placement (50) until manually
    # re-entered - confirmed by decoding Battlewrath's real re-exported
    # aura. The fragment now matches Tick.lua's default() table completely.
    end_cap_color = params.get("end_cap_color")
    if end_cap_color is not None:
        end_cap_fragment = _substitute(
            copy.deepcopy(FRAGMENT_TEMPLATES["class_accent_tick_end"]),
            {"end_cap_color": list(end_cap_color)},
        )
        result.setdefault("subRegions", []).append(end_cap_fragment)

    # NORMALIZE 2026-07-06: base_envelope() sets "conditions": {} (an empty
    # DICT, matching EXAMPLE_TEST_AURA's real envelope shape for an aura with
    # no conditions at all) - but every real conditions-bearing aura uses a
    # LIST (confirmed via REAL_MULTI_CONDITION_EXAMPLE_STRING, see below).
    # setdefault() only fills in an ABSENT key, so it silently left the
    # envelope's {} in place for every template that never happened to set
    # its own "conditions" key - caught immediately by testing this fill
    # against Lichfrost (AttributeError: 'dict' object has no attribute
    # 'append') before it could ship as a real, plausible-looking-but-broken
    # aura the way the v0.9 controlledChildren bug did.
    if not isinstance(result.get("conditions"), list):
        result["conditions"] = []

    # Load conditions (optional, UNIVERSAL - see load_conditions.schema.json).
    # Added 2026-07-08, per Battlewrath's real hand-built "LF Delta Test"
    # example (class=NECROMANCER + combat=true), decoded via
    # weakaura_codec.py. Deliberately NOT gated by template_name - unlike
    # every other optional block in this function, load conditions apply to
    # ANY template, since "load" is already part of every leaf aura's
    # envelope (base_envelope()'s own class/size/spec placeholders).
    # Confirmed real encoding: a multiselect-type field ("class") is a
    # companion "use_<name>" gate boolean plus a nested {single, multi}
    # value dict; a tristate-type field ("combat") is a single "use_<name>"
    # key carrying the tristate value directly (no companion value field).
    load_conditions = params.get("load_conditions")
    if load_conditions:
        load = result.setdefault("load", {})
        classes = load_conditions.get("classes")
        if classes:
            load["use_class"] = True
            if len(classes) == 1:
                load["class"] = {"single": classes[0], "multi": {}}
            else:
                # UNCONFIRMED shape for >1 classes - inferred by analogy
                # with the confirmed single-class case, not independently
                # live-tested. Flagged in load_conditions.schema.json too.
                load["class"] = {"single": classes[0], "multi": {c: True for c in classes}}
        combat = load_conditions.get("combat")
        if combat is not None:
            load["use_combat"] = bool(combat)

    # Glow source (optional) - see glow_source.schema.json's "verified" field.
    # CORRECTED 2026-07-04 against a real captured example
    # (weakaura_codec.REAL_MULTI_CONDITION_EXAMPLE_STRING, pasted and decoded
    # live): "conditions" is a LIST of {"changes", "check"} objects (not a
    # dict keyed by numbered strings, as this used to build it), and a
    # change's property path is "sub.N.<field>" where N is the glow
    # subRegion's 1-based POSITION in this aura's own subRegions array -
    # computed below dynamically, not hardcoded, since a stack_counter
    # overlay (added above) shifts that position.
    #
    # FIXED 2026-07-06: this used to hard-assign result["conditions"] = [...],
    # which would silently stomp a power_threshold fragment's own conditions
    # (added below) if both were ever used on the same aura - not yet hit in
    # practice (no real ability has needed both a proc AND a mana check
    # simultaneously), but fixed proactively now that a second conditions
    # producer exists, rather than waiting to discover the collision live.
    glow_source = params.get("glow_source")
    if glow_source:
        # LOOP FIX 2026-07-10: this used to hardcode `entry = glow_source[0]`
        # (a "settled scope: 1 for now" decision from 2026-07-04) - revised
        # after Battlewrath's real, live-tested Tormented Souls v4 build
        # proved the multi-entry case is real, not theoretical: it stacks a
        # buff_uptime entry (the ability's own granted buff) AND an
        # external_empower entry (an unrelated buff empowering it) on the
        # SAME icon simultaneously. Now iterates every entry, computing each
        # new trigger number fresh each pass (existing_nums must be
        # recomputed inside the loop, since each entry's own new trigger
        # changes what "existing" means for the next one).
        for entry in glow_source:
            existing_nums = [int(k) for k in result["triggers"].keys() if isinstance(k, str) and k.isdigit()]
            glow_trigger_num = max(existing_nums, default=1) + 1

            if entry["opportunity_type"] == "proc_alert":
                # UNCHANGED mechanism (sub.N.glow, a plain auto-reverting
                # boolean subRegion property) - Battlewrath's 2026-07-10 ask
                # was specifically about buff_uptime's "confirmation this
                # effect is active" case, not this one; the two stay visually
                # and mechanically distinct on purpose (see glow_source.schema
                # .json's "verified" field, REVISED 2026-07-10 note).
                glow_trigger = {
                    "type": "combatlog",
                    "event": "Combat Log",
                    "subeventPrefix": "SPELL",
                    "subeventSuffix": "_CAST_SUCCESS",
                    "spellIds": [str(entry["spell_id"])],
                    "use_spellId": True,
                }
                result["triggers"][str(glow_trigger_num)] = {"trigger": glow_trigger, "untrigger": {}}

                glow_position = next(
                    (i + 1 for i, sub in enumerate(result.get("subRegions", [])) if sub.get("type") == "subglow"),
                    None,
                )
                if glow_position is None:
                    raise ValueError(
                        f"Template '{template_name}' has a glow_source param but no "
                        "subglow entry in its subRegions - can't compute a 'sub.N.glow' "
                        "property path."
                    )

                # UNVERIFIED PIECE (see glow_source.schema.json's "verified"
                # field): the real captured example only shows a check against
                # TRIGGER 1's OWN "show" state, never a genuinely separate
                # trigger 2 - this trigger:N/variable:"show" check is inferred
                # by analogy from that confirmed syntax, not independently
                # confirmed for a truly separate trigger number. The list shape
                # and "sub.N.glow" property-path addressing below ARE confirmed.
                # "value": True FIXED 2026-07-10 (was a bare {"property": ...}
                # entry with no value key - harmless no-op for the desaturate
                # property elsewhere, since off is its own inferred default, but
                # sub.N.glow's "on" state DOES need its true value declared
                # explicitly, same as every other non-boolean-default Condition
                # change in this file).
                result.setdefault("conditions", []).append({
                    "changes": [{"property": f"sub.{glow_position}.glow", "value": True}],
                    "check": {"trigger": glow_trigger_num, "variable": "show", "value": 1},
                })
            elif entry["opportunity_type"] == "buff_uptime":
                # REVISED 2026-07-10, per Battlewrath's live-built and
                # live-tested Reaper "Tormented Souls" aura: glow mechanism
                # upgraded from sub.N.glow to "glowexternal" (LibCustomGlow's
                # Pixel-type border glow, applied directly to the aura's own
                # frame) - this reads as "confirmation this effect is active,"
                # colored to the parent template's own accent_color (class
                # accent hex), not a hand-picked one-off. glowexternal is an
                # IMPERATIVE action (glow_action: "show"/"hide"), not a
                # declarative property - it does NOT auto-revert, so a PAIRED
                # hide condition is required or the glow starts once and never
                # stops (confirmed the hard way live, in-game, by Battlewrath;
                # fix confirmed working in the same live test). See
                # glow_source.schema.json's "verified" field for the full trail.
                glow_trigger = {
                    "type": "aura2",
                    "unit": "player",
                    "debuffType": "HELPFUL",
                    "auraspellids": [str(entry["spell_id"])],
                    "useExactSpellId": True,
                    "ownOnly": True,
                }
                result["triggers"][str(glow_trigger_num)] = {"trigger": glow_trigger, "untrigger": {}}

                glow_frame = f"WeakAuras:{result['id']}"
                glow_color = list(fill_params.get("accent_color") or [1, 1, 1, 1])
                conditions = result.setdefault("conditions", [])
                conditions.append({
                    "check": {"trigger": glow_trigger_num, "variable": "show", "value": 1},
                    "changes": [{
                        "property": "glowexternal",
                        "value": {
                            "glow_action": "show",
                            "glow_type": "Pixel",
                            "glow_frame": glow_frame,
                            "glow_frame_type": "FRAMESELECTOR",
                            "glow_border": True,
                            "use_glow_color": True,
                            "glow_color": glow_color,
                        },
                    }],
                })
                conditions.append({
                    "check": {"trigger": glow_trigger_num, "variable": "show", "value": 0},
                    "changes": [{
                        "property": "glowexternal",
                        "value": {
                            "glow_action": "hide",
                            "glow_frame": glow_frame,
                            "glow_frame_type": "FRAMESELECTOR",
                        },
                    }],
                })
            elif entry["opportunity_type"] == "external_empower":
                # ADDED 2026-07-10 (second pass, same day), decoded directly
                # from Battlewrath's real Tormented Souls v4 build: an
                # AMBIENT, low-key texture overlay signaling that an
                # UNRELATED buff (not this ability's own granted result) is
                # currently empowering this ability - Battlewrath's own
                # framing: "rather than being flashy for attention... less
                # dramatics, but gives you reference to wait for that
                # state." Distinct from buff_uptime's glowexternal (an
                # attention-grabbing border trace) - this is deliberately
                # quieter, a plain declarative subtexture visibility toggle,
                # not an imperative glow action.
                #
                # Real capture's aura2 trigger also carried useStacks/
                # stacksOperator('<=')/stacks('1') - Battlewrath's own
                # words, "canceling out conditions," describing these as a
                # neutralized WeakAuras-UI artifact (trivially true for a
                # non-stacking buff, not real filtering). Deliberately NOT
                # reproduced here - a plain aura2 presence check achieves
                # the identical real-world result for Soul Infusion and
                # avoids a latent bug for any future empowering buff that
                # genuinely stacks past 1 (a literal stacks<=1 check would
                # then hide the texture at higher stacks, backwards from
                # intent). See glow_source.schema.json's "verified" field
                # for the full trail.
                empower_trigger = {
                    "type": "aura2",
                    "unit": "player",
                    "debuffType": "HELPFUL",
                    "auraspellids": [str(entry["spell_id"])],
                    "useExactSpellId": True,
                    "ownOnly": True,
                }
                result["triggers"][str(glow_trigger_num)] = {"trigger": empower_trigger, "untrigger": {}}

                texture_color = list(entry["texture_color"])
                texture_path = entry.get(
                    "texture_path",
                    "Interface\\Addons\\WeakAuras\\PowerAurasMedia\\Auras\\Aura1",
                )
                sub_regions = result.setdefault("subRegions", [])
                texture_position = next(
                    (i + 1 for i, sub in enumerate(sub_regions) if sub.get("type") == "subtexture"),
                    None,
                )
                if texture_position is None:
                    sub_regions.append({
                        "type": "subtexture",
                        "textureTexture": texture_path,
                        "textureColor": texture_color,
                        "textureBlendMode": "ADD",
                        "textureVisible": True,
                        "textureDesaturate": False,
                        "width": 32,
                        "height": 32,
                        "scale": 1,
                        "anchor_mode": "area",
                        "anchor_area": "ALL",
                        "anchor_point": "CENTER",
                        "self_point": "CENTER",
                        "rotate": False,
                        "textureRotate": False,
                        "textureRotation": 0,
                        "mirror": False,
                        "textureMirror": False,
                    })
                    texture_position = len(sub_regions)

                # BOTH states explicit (unlike desaturate's inferred-off
                # convention) - this subtexture's own baseline
                # textureVisible is true, not false, so the "hide" half
                # must be stated or it would never revert. A declarative
                # property toggle (like sub.N.glow), not glowexternal's
                # imperative action - no automatic-revert risk here, but
                # the pair is still needed because the property's OWN
                # default is "on."
                conditions = result.setdefault("conditions", [])
                conditions.append({
                    "check": {"trigger": glow_trigger_num, "variable": "show", "value": 1},
                    "changes": [{"property": f"sub.{texture_position}.textureVisible", "value": True}],
                })
                conditions.append({
                    "check": {"trigger": glow_trigger_num, "variable": "show", "value": 0},
                    "changes": [{"property": f"sub.{texture_position}.textureVisible", "value": False}],
                })
            else:  # target_debuff_presence
                # ADDED 2026-07-10 (third pass, same day), decoded directly
                # from Battlewrath's real, live-built and live-tested
                # "Murder" (502679) Rotation-tier aura. A boolean CONDITION
                # CHECK, not a DoT/duration tracker - Battlewrath's own
                # words: "this checks if my target has my debuff on it.
                # This is not a DOT tracker in the broad sense. More a
                # condition checker." unit:"target" is the load-bearing
                # difference from every other aura2 trigger in this
                # project so far (all previously unit:"player") - the
                # debuff is one the PLAYER applies (ownOnly:true) but the
                # presence check reads the TARGET's own aura list.
                #
                # Uses the SIMPLER internal-subglow mechanism Battlewrath
                # discovered this same session ("I didn't know I can
                # declare an internal glow effect, so I used the external
                # and pointed it on it's self. I've since learned about
                # making a glow, internal, but turned off. And then a
                # condition turning it onto visible.") - an ordinary
                # internal subglow subRegion configured with glowType
                # 'Pixel'/useGlowColor true/a custom glowColor (not just
                # proc_alert's plain 'buttonOverlay' type), toggled via the
                # SAME declarative "sub.N.glow" property Condition
                # proc_alert already uses - a SINGLE Condition (no paired
                # hide needed, confirmed by the real capture having only
                # one condition for this signal: the declarative auto-
                # revert class, same as desaturate/proc_alert's sub.N.glow,
                # NOT glowexternal's imperative no-auto-revert class). This
                # is simpler than glowexternal on every axis (no frame-
                # selector self-targeting, no imperative glow_action pair)
                # - kept as a documented ALTERNATIVE rather than
                # retroactively rewriting buff_uptime's own already-shipped
                # glowexternal mechanism above; future opportunity_types
                # needing a border-glow confirmation signal should default
                # to THIS simpler approach unless a real reason favors
                # glowexternal specifically. See glow_source.schema.json's
                # "verified" field for the full trail.
                presence_trigger = {
                    "type": "aura2",
                    "unit": "target",
                    "debuffType": "HARMFUL",
                    "auraspellids": [str(entry["spell_id"])],
                    "useExactSpellId": True,
                    "ownOnly": True,
                }
                result["triggers"][str(glow_trigger_num)] = {"trigger": presence_trigger, "untrigger": {}}

                glow_color = list(entry["glow_color"])
                sub_regions = result.setdefault("subRegions", [])
                sub_regions.append({
                    "type": "subglow",
                    "glow": False,
                    "glowType": "Pixel",
                    "useGlowColor": True,
                    "glowColor": glow_color,
                    "glowLines": 8,
                    "glowFrequency": 0.25,
                    "glowDuration": 1,
                    "glowLength": 10,
                    "glowThickness": 1,
                    "glowScale": 1,
                    "glowBorder": False,
                    "glowXOffset": 0,
                    "glowYOffset": 0,
                })
                glow_position = len(sub_regions)

                result.setdefault("conditions", []).append({
                    "check": {"trigger": glow_trigger_num, "variable": "show", "value": 1},
                    "changes": [{"property": f"sub.{glow_position}.glow", "value": True}],
                })

    # Power-threshold effect (optional) - see power_threshold_effect.schema.json.
    # Added 2026-07-06, direct real-source consumer: Necromancer's Lichfrost/
    # Crypt Swarm/Command: Undead. Unlike glow_source's cross-trigger "show"
    # check above (inferred by analogy, not independently confirmed), this
    # mechanism's generated code shape IS independently confirmed straight
    # from Conditions.lua's CreateTestForCondition (the cType=='number'
    # branch): state[trigger] and state[trigger].show and
    # state[trigger][variable] ~= nil and state[trigger][variable] <op> value.
    # Deliberately drives effects only (desaturate, and optionally glow) -
    # never visibility, per Battlewrath's explicit correction that rotation
    # slots are fixed/always-visible.
    power_threshold = params.get("power_threshold")
    if power_threshold:
        powertype = power_threshold["powertype"]
        cost = power_threshold["cost"]
        cost_is_percent = power_threshold.get("cost_is_percent", False)
        include_afford_glow = power_threshold.get("include_afford_glow", False)
        cost_field = "percentpower" if cost_is_percent else "power"

        power_trigger = {
            "type": "unit",
            "event": "Power",
            "unit": "player",
            "use_powertype": True,
            "powertype": powertype,
        }
        existing_nums = [int(k) for k in result["triggers"].keys() if isinstance(k, str) and k.isdigit()]
        power_trigger_num = max(existing_nums, default=1) + 1
        result["triggers"][str(power_trigger_num)] = {"trigger": power_trigger, "untrigger": {}}

        conditions = result.setdefault("conditions", [])
        conditions.append({
            "changes": [{"property": "desaturate", "value": 1}],
            "check": {"trigger": power_trigger_num, "variable": cost_field, "op": "<", "value": str(cost)},
        })

        if include_afford_glow:
            glow_position = next(
                (i + 1 for i, sub in enumerate(result.get("subRegions", [])) if sub.get("type") == "subglow"),
                None,
            )
            if glow_position is None:
                raise ValueError(
                    f"Template '{template_name}' has power_threshold.include_afford_glow "
                    "but no subglow entry in its subRegions - can't compute a "
                    "'sub.N.glow' property path."
                )
            conditions.append({
                "changes": [{"property": f"sub.{glow_position}.glow", "value": 1}],
                "check": {"trigger": power_trigger_num, "variable": cost_field, "op": ">=", "value": str(cost)},
            })

    # Show-when-missing + show-stacks (optional, buff_uptime_aurabar only) -
    # see build_templates.py's BUFF_UPTIME_AURABAR_SCHEMA. Added 2026-07-09
    # for Reaper's Soul Fragment (805077), formalizing Battlewrath's own
    # live-tested "anti statement" second-trigger fix ("Yes that fixed it")
    # for the footprint-disappears-when-absent problem, plus the
    # still-missing stack-count subtext.
    if template_name == "buff_uptime_aurabar":
        if params.get("show_when_missing"):
            missing_trigger = {
                "type": "aura2",
                "event": "Health",
                "unit": "player",
                "debuffType": "HELPFUL",
                "auraspellids": [str(params["spell_id"])],
                "useExactSpellId": True,
                "ownOnly": True,
                "matchesShowOn": "showOnMissing",
            }
            existing_nums = [int(k) for k in result["triggers"].keys() if isinstance(k, str) and k.isdigit()]
            missing_trigger_num = max(existing_nums, default=1) + 1
            result["triggers"][str(missing_trigger_num)] = {"trigger": missing_trigger, "untrigger": {}}
            result["triggers"]["disjunctive"] = "any"

        if params.get("show_stacks"):
            stacks_subtext = {
                "type": "subtext",
                "text_text": "%s",
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
            }
            result.setdefault("subRegions", []).append(stacks_subtext)

    # Background-color override (optional, backing_plate_aurabar only) - see
    # build_templates.py's BACKING_PLATE_AURABAR_SCHEMA "background_color"
    # property. Added 2026-07-09 for the new center-seam divider-strip use
    # case (a plain instance of this already-proven template, resized/
    # recolored, replacing class_accent_tick_end after live-testing found
    # the tick's AtPercent placement hides whenever the active trigger lacks
    # real progress data - see that schema's own note for the full trail).
    if template_name == "backing_plate_aurabar":
        background_color = params.get("background_color")
        if background_color is not None:
            result["backgroundColor"] = list(background_color)

    # Desaturate-on-cooldown (optional, cooldown_tracker_icon only) - see
    # build_templates.py's COOLDOWN_TRACKER_ICON_SCHEMA "desaturate_on_
    # cooldown" property. Added 2026-07-09 for Skeletal Archers (805040),
    # per Battlewrath: "Show when available. Then desaturate whilst on
    # cooldown... see if this can be handled as one WA item, instead of 2
    # (backplate vs live)." Answer: yes - this checks trigger 1's OWN
    # "duration" state field (already set by the Cooldown Progress (Spell)
    # trigger every template of this kind already has - 0 when available,
    # the real cooldown length while cooling down, confirmed by direct
    # source read of Prototypes.lua). No second trigger, no backing_plate_
    # icon pairing - a single Condition on the one trigger this template
    # already carries.
    if params.get("desaturate_on_cooldown"):
        result.setdefault("conditions", []).append({
            "changes": [{"property": "desaturate", "value": 1}],
            "check": {"trigger": 1, "variable": "duration", "op": ">", "value": "0"},
        })

    # Press-wash effect (optional) - see press_wash_effect.schema.json.
    # Added 2026-07-06, per Battlewrath's piano-key analogy ("press a key
    # and get a response") - per-ability "I touched this" feedback,
    # independent per icon, scoped only to abilities that don't already get
    # a cooldown sweep as their response (Battlewrath: "those with
    # cooldowns don't need it"). A second Combat Log trigger (this icon's
    # own spell, duration=0.3 for native auto-revert - see the fragment's
    # own "verified" field for the full GenericTrigger.lua confirmation)
    # drives a single Condition that mixes the icon's base "color" toward
    # its accent_color, then reverts automatically when the trigger's own
    # timed show flips back false - same single-direction Condition
    # pattern as power_threshold/glow_source above (no manual "revert"
    # entry needed).
    #
    # CORRECTED 2026-07-06, after a real in-game test (v2, pasted and
    # decoded) surfaced two real gaps in the first version:
    # 1. MISSING SOURCE FILTER - v2 never set sourceUnit/use_sourceUnit, so
    #    the trigger matched Combat Log events from ANY unit, not just the
    #    player ("they all landed with no spell config... firing to any
    #    combat event"). Fixed: use_sourceUnit=true, sourceUnit="player".
    # 2. NAME-BASED, NOT ID-BASED, SPELL FILTER - v2 used spellIds/
    #    use_spellId=true (copied from proc_alert_icon's existing pattern,
    #    itself flagged as "not independently re-verified"). Battlewrath's
    #    real fix uses use_spellName=true + spellName=[name] instead -
    #    DELIBERATE, not a bug workaround: "Spell ID can be a source. But I
    #    made it generic incase the ranks effect things. So targetted the
    #    spell name" - different ranks of the same spell carry different
    #    spell IDs but the same name, so name-based matching is robust
    #    across ranks where ID-based would only catch one specific rank.
    # Both fixes are load-bearing and applied below.
    #
    # CAST_START vs CAST_SUCCESS - RESOLVED 2026-07-06 (v4), after a second
    # live-test round. v3's open question ("why did Crypt Swarm/Command:
    # Undead never fire under _CAST_START while Lichfrost did") is now
    # answered: Battlewrath swapped Crypt Swarm to _CAST_SUCCESS and it
    # started firing correctly, then stated the general rule directly -
    # "true cast start = spells with a cast time. Cast success = spells
    # with instant." Cross-checked against real db.ascension.gg spell data
    # (2026-07-06) to sharpen this into the precise WoW combat-log rule:
    #   - Lichfrost (501969): real 1.5s cast time (a true windup/cast bar)
    #     -> _CAST_START (WoW fires SPELL_CAST_START at windup begin,
    #     SPELL_CAST_SUCCESS only at completion - _CAST_START is the
    #     "I pressed this" moment here).
    #   - Crypt Swarm (500965): "Channeled" cast time, not a normal windup
    #     -> _CAST_SUCCESS (WoW fires SPELL_CAST_SUCCESS the instant a
    #     channel begins - there is no separate CAST_START event for a
    #     channeled spell the way there is for a windup cast).
    #   - Command: Undead (504868): "Instant cast" -> _CAST_SUCCESS
    #     (instant spells only ever emit SPELL_CAST_SUCCESS, no CAST_START).
    # So the real rule is windup-cast-time vs (instant OR channeled), not
    # simply "has a cast time" vs "instant" as first stated - channeled
    # spells behave like instant casts for this specific event, despite
    # visually having a "cast time" (a channel duration) on their tooltip.
    # Selected per-ability via the new trigger_event param below (default
    # "cast_success"; Lichfrost is the only current exception, set to
    # "cast_start" in Necromancer/inventory.py).
    #
    # Command: Undead STILL not observed firing in-game even at the
    # (correct, instant-cast) _CAST_SUCCESS suffix, per Battlewrath's
    # 2026-07-06 live report - left as-is and NOT further debugged this
    # pass: Battlewrath judged it non-blocking, since Command: Undead
    # already gets its own per-press feedback signal for free via its
    # existing afford-glow (trigger 2, Runic Power >= 30) cycling on/off
    # as its 30 RP cost is spent and regenerated - "that has feed back in
    # the glow once you press it enough times." Revisit only if this
    # becomes a real problem in practice.
    #
    # DISJUNCTIVE: unlike power_threshold's own second trigger (Power, a
    # continuous status - always active, so AND-combining with trigger 1's
    # showAlways is a no-op), this trigger is genuinely momentary (0.3s per
    # cast). WeakAuras.lua line 3109 defaults multi-trigger "disjunctive" to
    # "all" (AND) unless set otherwise. Explicitly set to "any" (OR) here so
    # trigger 1's own showAlways alone keeps the icon permanently visible,
    # same as before this fragment existed.
    press_wash = params.get("press_wash")
    if press_wash:
        wash_alpha = press_wash.get("wash_alpha", 0.3)
        duration = press_wash.get("duration", 0.3)
        accent = fill_params.get("accent_color") or [1, 1, 1, 1]
        # trigger_event: "cast_success" (default - instant AND channeled
        # spells) or "cast_start" (windup/cast-time spells only) - see the
        # long comment block above for the confirmed WoW combat-log rule
        # and per-ability values (Lichfrost is currently the only
        # "cast_start" case).
        trigger_event = press_wash.get("trigger_event", "cast_success")
        subevent_suffix = "_CAST_START" if trigger_event == "cast_start" else "_CAST_SUCCESS"

        wash_color = [
            1 * (1 - wash_alpha) + accent[0] * wash_alpha,
            1 * (1 - wash_alpha) + accent[1] * wash_alpha,
            1 * (1 - wash_alpha) + accent[2] * wash_alpha,
            1,  # region alpha untouched - this is a tint mix, never a fade
        ]

        wash_trigger = {
            "type": "combatlog",
            "event": "Combat Log",
            "subeventPrefix": "SPELL",
            "subeventSuffix": subevent_suffix,
            "use_sourceUnit": True,
            "sourceUnit": "player",
            "use_spellName": True,
            "spellName": [str(params["name"])],
            "use_spellId": False,
            "duration": str(duration),
            "use_duration": True,
        }
        existing_nums = [int(k) for k in result["triggers"].keys() if isinstance(k, str) and k.isdigit()]
        wash_trigger_num = max(existing_nums, default=1) + 1
        result["triggers"][str(wash_trigger_num)] = {"trigger": wash_trigger, "untrigger": {}}
        result["triggers"]["disjunctive"] = "any"

        result.setdefault("conditions", []).append({
            "changes": [{"property": "color", "value": wash_color}],
            "check": {"trigger": wash_trigger_num, "variable": "show", "value": 1},
        })

    # Stack-delta flash text (stack_delta_flash_text only) - the Lua "custom"
    # field embeds spell_id/aura_filter/label_suffix/duration INSIDE one long
    # function-literal string, which the generic {{}} _substitute() pass
    # above can't reach (its regex only matches a leaf that IS entirely one
    # placeholder). Filled here via a dedicated .format() pass instead - see
    # stack_delta_flash_text.schema.json's "verified" field for why this is
    # deliberately kept separate from the {{}} mechanism (every literal Lua
    # table-constructor brace in the template is pre-doubled to "{{ }}" so
    # .format() leaves it as a single literal brace).
    if template_name == "stack_delta_flash_text":
        aura_filter = params["aura_filter"]
        spell_id = params["spell_id"]
        label_suffix = params.get("label_suffix", schema["properties"]["label_suffix"]["default"])
        duration = params.get("duration", schema["properties"]["duration"]["default"])
        trig = result["triggers"]["1"]["trigger"]
        trig["custom"] = trig["custom"].format(
            aura_filter=aura_filter,
            spell_id=spell_id,
            label_suffix=label_suffix,
            duration=duration,
        )

    # Fallback icon (backing_plate_icon only) - see backing_plate_icon.
    # schema.json's "fallback_icon" note. REVISED 2026-07-08: the original
    # blank-dim-square backing plate was live-tested and reported failing
    # ("it has no icon") - when a real spell ID/texture is supplied, show
    # that icon instead, desaturated, no border, per Battlewrath's own
    # proposed fix. iconSource=0 (manual) tells RegionTypes/Icon.lua's
    # UpdateIcon to read displayIcon directly instead of a trigger's own
    # state.icon - confirmed by direct source read, not inferred.
    if template_name == "backing_plate_icon":
        fallback_icon = params.get("fallback_icon")
        if fallback_icon is not None:
            result["icon"] = True
            result["iconSource"] = 0
            result["displayIcon"] = str(fallback_icon)
            result["desaturate"] = True

        # Color tint override (backing_plate_icon only) - see that schema's
        # "color" property note. Added 2026-07-08 (third pass) alongside
        # missing_state_option_names below, since Battlewrath's real edit
        # re-tinted this to a muted grey to suit a real icon showing through.
        color = params.get("color")
        if color is not None:
            result["color"] = list(color)

        # Missing-state icon-source override (backing_plate_icon only) - see
        # backing_plate_icon.schema.json's "missing_state_option_names" note.
        # Formalizes Battlewrath's own real, hand-edited fix for Undead
        # Stance Backing: "It is basically an anti statement. If neither of
        # those auras are present, then show the desaturated version." Adds
        # a second aura2 trigger (matchesShowOn: showOnMissing, same names as
        # the paired stance_loader_icon's option_names) so WeakAuras resolves
        # an icon for the named spell(s) BY NAME, live in-game - no spellId
        # needed on our side at all, unlike fallback_icon above. A Condition
        # then flips iconSource to that trigger's own number when it's
        # active. No 'event'/subeventPrefix/subeventSuffix keys on this
        # trigger - confirmed absent in Battlewrath's real captured export
        # (see schema's "verified" field), so deliberately omitted here too
        # rather than copied from stance_loader_icon's own aura2 shape.
        # desaturate forced true (matches the real captured value) - icon/
        # iconSource are left at their base false/-1 in this static fill;
        # the iconSource override only happens at runtime via the Condition.
        missing_state_option_names = params.get("missing_state_option_names")
        if missing_state_option_names:
            missing_trigger = {
                "type": "aura2",
                "unit": "player",
                "auranames": [str(n) for n in missing_state_option_names],
                "useName": True,
                "matchesShowOn": "showOnMissing",
                "ownOnly": True,
                "debuffType": "HELPFUL",
            }
            existing_nums = [int(k) for k in result["triggers"].keys() if isinstance(k, str) and k.isdigit()]
            missing_trigger_num = max(existing_nums, default=1) + 1
            result["triggers"][str(missing_trigger_num)] = {"trigger": missing_trigger, "untrigger": {}}

            result["desaturate"] = True
            result.setdefault("conditions", []).append({
                "changes": [{"property": "iconSource", "value": missing_trigger_num}],
                "check": {"trigger": missing_trigger_num, "variable": "show", "value": 1},
            })

    # Stance loader (stance_loader_icon only) - builds N mutually-exclusive
    # aura2 triggers from option_names, one per option, name-matched (no
    # spell ID available/needed - see stance_loader_icon.schema.json's
    # "verified" field). Dynamic trigger count is why STANCE_LOADER_ICON_
    # TEMPLATE ships with "triggers": {} rather than a fixed shape like
    # every other template here - built entirely here instead.
    # disjunctive="any": without it, the default AND-combination would
    # require every option's trigger active simultaneously - impossible for
    # mutually-exclusive states, so the icon would never show at all.
    # activeTriggerMode=-10 ("first_active", already this project's default
    # via base template dicts) then picks whichever ONE trigger is active
    # and the icon auto-resolves its own art from that trigger's state
    # (RegionTypes/Icon.lua's iconSource=-1 branch) - no Conditions block
    # or manual icon-swap needed.
    if template_name == "stance_loader_icon":
        option_names = params["option_names"]
        triggers = {}
        for i, opt_name in enumerate(option_names, start=1):
            triggers[str(i)] = {
                "trigger": {
                    "type": "aura2",
                    "event": "Health",
                    "unit": "player",
                    "debuffType": "HELPFUL",
                    "useName": True,
                    "auranames": [str(opt_name)],
                    "ownOnly": True,
                    "subeventPrefix": "SPELL",
                    "subeventSuffix": "_CAST_START",
                },
                "untrigger": {},
            }
        triggers["activeTriggerMode"] = -10
        triggers["disjunctive"] = "any"
        result["triggers"] = triggers

        # Optional per-option border color (added 2026-07-08, real bug fix -
        # see stance_loader_icon.schema.json's "border_colors" property note:
        # iconSource=-1 was resolving to the same icon art for all 3 Undead
        # Stance options in-game, so a border color per trigger is the actual
        # distinguishing signal, not a different icon-art mechanism. Same
        # "sub.N.<field>" Condition-addressing pattern as glow_source above,
        # just one condition per option instead of one - each option's own
        # trigger index directly maps to its own condition (trigger i active
        # -> border shows option i's color).
        border_colors = params.get("border_colors")
        if border_colors:
            if len(border_colors) != len(option_names):
                raise ValueError(
                    "stance_loader_icon: border_colors must have the same "
                    f"length as option_names ({len(option_names)}), got "
                    f"{len(border_colors)}."
                )
            sub_regions = result.setdefault("subRegions", [])
            border_position = next(
                (i + 1 for i, sub in enumerate(sub_regions) if sub.get("type") == "subborder"),
                None,
            )
            if border_position is None:
                sub_regions.append({
                    "type": "subborder",
                    "border_size": 2,
                    "border_color": [1, 1, 1, 1],
                    "border_visible": True,
                    "border_edge": "Square Full White",
                    "border_offset": 0,
                })
                border_position = len(sub_regions)
            conditions = result.setdefault("conditions", [])
            for i, color in enumerate(border_colors, start=1):
                conditions.append({
                    "changes": [{"property": f"sub.{border_position}.border_color", "value": list(color)}],
                    "check": {"trigger": i, "variable": "show", "value": 1},
                })

    result["triggers"] = _intify_trigger_keys(result["triggers"])
    return result


def list_templates():
    return sorted(REGISTRY)


if __name__ == "__main__":
    print("Available templates:")
    for name in list_templates():
        schema, _ = _load_pair(name)
        print(f"  {name:32s} -> {schema['opportunity_type']:24s} ({schema['region_type']})")
