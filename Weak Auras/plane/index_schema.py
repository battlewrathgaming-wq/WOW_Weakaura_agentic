"""
index_schema.py - the WA index as the SCHEMA AUTHORITY for part derivation.

The index (wa_index/index.json) enumerates every legitimate lever per namespace.
This module turns it into, per part-namespace:
  * allowlist  - the set of STORED field names a clean part of that namespace may
                 hold (config lever + its stored machinery); anything outside is
                 residue, dropped by construction (blank slate, not scrub-after).
  * slots      - the fillable content surface (typed), i.e. the "stream of content"
                 the class inventory populates.

Lane-dependent, because the index and WA store fields differently per lane:
  trigger/load config levers are OPTIONAL   -> stored as use_<name> + <name>
                                               (+ spell companions real<Name>/use_exact_<name>)
  region levers are FIELDS, always present  -> stored directly as <name>
  state-role levers are runtime OUTPUTS     -> never stored (excluded from allowlist)

The index is complete & authoritative for trigger/load/subregion namespaces (strict
allowlist is safe). It is NOT a complete stored-field enumeration for regions (omits
shared alpha, Masque BFskin, use_ variants), so region callers use `region_fields`
for the slot catalogue but drop residue by an explicit foreign-meta set, not by strict
allowlist. See derive_contracts.py.
"""
import json
import os

_THIS = os.path.dirname(os.path.abspath(__file__))
_WA = os.path.dirname(_THIS)
_INDEX = os.path.join(_WA, "wa_index", "index.json")

# structural keys every trigger core carries, set by choosing the namespace itself
_TRIG_STRUCT = {"event", "type"}
# aura-level provenance/meta that is NOT indexed and must never be inherited from a
# harvested instance. `information` is a real WA field but its contents are authoring
# toggles (opt-in options), so it is reset to {} rather than inherited. `version`/`desc`
# are authored by us (inventory), not dropped - handled in the assembler, not here.
FOREIGN_META = {"url", "wagoID", "source", "semver", "id", "uid"}
AUTHORED_META = {"version", "desc"}          # ours to author, never inherit a pack's


def load_index():
    return json.load(open(_INDEX, encoding="utf-8"))


def _cap(n):
    return n[0].upper() + n[1:] if n else n


def _levers(idx, section, namespace):
    return [e for e in idx if e["section"] == section and e["namespace"] == namespace]


def trigger_schema(idx, event):
    """(allowlist, slots) for a trigger namespace (event == namespace string).
    allowlist = stored field names a clean core may hold. slots = typed fillable
    config surface (the content stream)."""
    levers = _levers(idx, "trigger", event)
    allow = set(_TRIG_STRUCT)
    slots = []
    for e in levers:
        n = e["name"]
        if e.get("input_kind") == "state":      # runtime output, never stored
            continue
        if e["type"] in ("description",) or e.get("input_kind") == "ui":
            continue                              # UI-only (titles, collapses)
        allow.add(n)
        allow.add("use_" + n)
        if e["type"] == "spell":
            allow.add("use_exact_" + n)
            allow.add("real" + _cap(n))
        slots.append({"name": n, "type": e["type"], "input": e.get("input_kind"),
                      "default": e.get("default"), "values": e.get("values")})
    return allow, slots


def subregion_schema(idx, sub_ns):
    """(allowlist, slots) for a subRegion namespace (e.g. 'subtext'). subRegions store
    `type` plus their fields; index subregion levers are the field surface."""
    levers = _levers(idx, "subregion", sub_ns)
    allow = {"type"}
    slots = []
    for e in levers:
        n = e["name"]
        if e.get("input_kind") == "state" or e["type"] == "description":
            continue
        allow.add(n)
        slots.append({"name": n, "type": e["type"], "input": e.get("input_kind"),
                      "default": e.get("default"), "values": e.get("values")})
    return allow, slots


def region_fields(idx, region_ns):
    """Slot catalogue (typed) for a region body's display fields (role=='field').
    NOT used as a strict allowlist - region stored-fields exceed the index (shared/
    skinning); the deriver keeps display fields and drops FOREIGN_META explicitly."""
    slots = []
    for e in _levers(idx, "region", region_ns):
        if e["role"] != "field":
            continue
        slots.append({"name": e["name"], "type": e["type"], "input": e.get("input_kind"),
                      "default": e.get("default"), "values": e.get("values")})
    # shared fields (alpha, etc.) apply to every region
    for e in _levers(idx, "region", "_shared"):
        if e["role"] == "field":
            slots.append({"name": e["name"], "type": e["type"], "input": e.get("input_kind"),
                          "default": e.get("default"), "values": e.get("values")})
    return slots


def region_change_targets(idx, region_ns):
    """Property names conditions may set on this region (role=='change') - the join
    former's change vocabulary (e.g. desaturate, color)."""
    return sorted({e["name"] for e in _levers(idx, "region", region_ns)
                   if e["role"] == "change"})


def load_slots(idx, lever_names):
    """(allowlist, slots) for a load PART restricted to an explicit purpose-subset of
    load levers (e.g. ['class'] for load.by_class). Load levers store as use_<name> +
    <name>; the rest of the load vocabulary is not this part's purpose -> excluded."""
    by_name = {e["name"]: e for e in _levers(idx, "load", "")}
    allow = set()
    slots = []
    for n in lever_names:
        e = by_name.get(n)
        if e is None:
            raise SystemExit(f"load lever {n!r} not in index")
        allow.add(n)
        allow.add("use_" + n)
        slots.append({"name": n, "type": e["type"], "input": e.get("input_kind"),
                      "default": e.get("default"), "values": e.get("values")})
    return allow, slots
