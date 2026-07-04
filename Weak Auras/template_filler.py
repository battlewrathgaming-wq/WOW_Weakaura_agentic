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
        entry = glow_source[0]  # settled scope: 1 glow-source for now
        if entry["opportunity_type"] == "proc_alert":
            glow_trigger = {
                "type": "combatlog",
                "event": "Combat Log",
                "subeventPrefix": "SPELL",
                "subeventSuffix": "_CAST_SUCCESS",
                "spellIds": [str(entry["spell_id"])],
                "use_spellId": True,
            }
        else:  # buff_uptime
            glow_trigger = {
                "type": "aura2",
                "event": "Health",
                "unit": "player",
                "debuffType": "HELPFUL",
                "spellIds": [str(entry["spell_id"])],
                "useExactSpellId": True,
                "ownOnly": True,
                "names": [],
                "subeventPrefix": "SPELL",
                "subeventSuffix": "_CAST_START",
            }
        existing_nums = [int(k) for k in result["triggers"].keys() if isinstance(k, str) and k.isdigit()]
        glow_trigger_num = max(existing_nums, default=1) + 1
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

        # UNVERIFIED PIECE (see glow_source.schema.json's "verified" field):
        # the real captured example only shows a check against TRIGGER 1's
        # OWN "show" state, never a genuinely separate trigger 2 - this
        # trigger:N/variable:"show" check is inferred by analogy from that
        # confirmed syntax, not independently confirmed for a truly separate
        # trigger number. The list shape and "sub.N.glow" property-path
        # addressing below ARE confirmed (and, separately, power_threshold's
        # own cross-trigger check below IS independently confirmed via
        # Conditions.lua directly - see that block's comment).
        result.setdefault("conditions", []).append({
            "changes": [{"property": f"sub.{glow_position}.glow"}],
            "check": {"trigger": glow_trigger_num, "variable": "show", "value": 1},
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

    result["triggers"] = _intify_trigger_keys(result["triggers"])
    return result


def list_templates():
    return sorted(REGISTRY)


if __name__ == "__main__":
    print("Available templates:")
    for name in list_templates():
        schema, _ = _load_pair(name)
        print(f"  {name:32s} -> {schema['opportunity_type']:24s} ({schema['region_type']})")
