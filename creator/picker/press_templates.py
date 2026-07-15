"""press_templates.py - Phase 2: the V1 lane templates + behaviour fragments, pressed by the REAL machine.

Nothing here hand-writes a stored form. Sources are proven dockets:
  dot_target   the Target tracker contract's own press (populate.py, NECROMANCER Death; Blight = the reference
               member) - fragment variants: APPEAR (the pressed default: matchesShowOn=showOnActive) and
               PERSIST (matchesShowOn=showAlways + the corpus-proven show==0 -> desaturate condition,
               Blight's own docket form; domain: bufftrigger_2_progress_behavior_types).
  dot_multi    the corpus multidot pattern's closed dockets (DOT member + DOTS group) - single form
               (the catch-all IS the react read; picker_tree Q4).
  pet          the guardian-health-tracker scaffold's closed dockets (Pet_health_spawner member +
               Pet_health_test group) - ships as the one proven shape; custom Lua rides VERBATIM
               (authored on the addons bench - the charter's lane).

Every docket (including fragment variants) goes through the GATE, then the proven chain
(expand -> fill -> bounce; bounce = reconcile(canon(...)) - WA's own acceptor inside).
Output: out/templates.json - pressed tables + slot annotations (the paths the shell substitutes).

  py press_templates.py     -> out/templates.json + a receipt
"""
import copy
import json
import os
import shutil
import subprocess
import sys

_HERE = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.abspath(os.path.join(_HERE, "..", ".."))
_PLANNING = os.path.join(_ROOT, "creator", "planning")
_PLANE = os.path.join(_ROOT, "Weak Auras", "plane")
_ENGINE = os.path.join(_ROOT, "Weak Auras", "engine")
_AUTHORED = os.path.join(_ENGINE, "Production", "_authored")
_CORPUS_OUT = os.path.join(_ROOT, "corpus", "planning", "out")
OUT = os.path.join(_HERE, "out", "templates.json")

sys.path.insert(0, _PLANE)
sys.path.insert(0, _ENGINE)
import expand  # noqa: E402
import fill    # noqa: E402
import reconcile as rec  # noqa: E402
import gate as gatemod   # noqa: E402

GROUP_REGIONS = ("dynamicgroup", "group")
REF_PID = "necromancer-death-target"
REF_MEMBER = "Blight"


def press_docket(docket):
    """ANY docket -> a bounced (canon-completed, reconciled) aura table - bundle's own rule:
    a reasoning docket (triggers lack declare) or a group goes through expand first."""
    reasoning = any("declare" not in t for t in (docket.get("triggers") or [])) if docket.get("triggers") else False
    is_group = docket.get("regionType", docket.get("region")) in GROUP_REGIONS
    full = expand.expand(docket) if (reasoning or is_group) else docket
    return rec.bounce(fill.fill(full))


def gate_or_die(docket, label):
    r = gatemod.gate(docket)
    for f in r["flags"]:
        print(f"    gate[{label}] {f['verdict']:9s} {f['path']}  {f['note']}")
    if not r["passed"]:
        raise SystemExit(f"GATE BLOCKED: {label} - {r['blocking']}")
    return docket


def reference_dockets():
    """Press the Target tracker contract for the reference pair; lift the group + Blight
    dockets from _authored/ (FLAT: <pid>__<Member>.docket.json). Leave the machine as
    found: snapshot before the run, delete ONLY what this run created."""
    before = set(os.listdir(_AUTHORED)) if os.path.isdir(_AUTHORED) else set()
    p = subprocess.run([sys.executable, os.path.join(_PLANNING, "populate.py"),
                        os.path.join(_PLANNING, "target_tracker.contract.json"),
                        "NECROMANCER", "Death"],
                       capture_output=True, text=True, cwd=_PLANNING)
    if p.returncode != 0:
        raise SystemExit(f"populate failed:\n{p.stderr[:400]}")
    created = sorted(set(os.listdir(_AUTHORED)) - before)
    # Lift by NAME (populate just refreshed them; the press is proven deterministic) -
    # _authored may hold these files permanently as tracked residents, so a created-diff
    # can't be the lift. Cleanup still removes ONLY genuinely-new files.
    group = member = None
    try:
        for f in sorted(os.listdir(_AUTHORED)):
            if not (f.startswith(REF_PID + "__") and f.endswith(".docket.json")):
                continue
            d = json.load(open(os.path.join(_AUTHORED, f), encoding="utf-8"))
            if d.get("regionType") in GROUP_REGIONS:
                group = d
            elif d.get("id") == REF_MEMBER:
                member = d
    finally:
        for f in created:  # only THIS run's files; pre-existing residents untouched
            os.remove(os.path.join(_AUTHORED, f))
    if not group or not member:
        raise SystemExit(f"reference press missing group/member ({REF_PID}; created {len(created)})")
    return group, member


def persist_variant(member_docket):
    """The PERSIST fragment: always in place, dims while the aura is missing.
    matchesShowOn=showAlways + condition buffed==0 -> desaturate.
    LIVE-CORRECTED (Battlewrath, 2026-07-16, export_20260716_000029_01): under showAlways the
    trigger's `show` is ALWAYS 1, so a show==0 condition never fires ("it was always showing") -
    the aura-state variable is `buffed` ("Aura(s) Found" in the UI). The lane's read: duration
    swipe + full colour only while MY debuff is on them = the should-I-debuff check."""
    d = copy.deepcopy(member_docket)
    d["triggers"][0]["declare"]["matchesShowOn"] = "showAlways"
    d["conditions"] = [{"check": {"trigger": 1, "variable": "buffed", "value": 0},
                        "changes": {"desaturate": True}}]
    return d


def corpus_docket(name):
    d = json.load(open(os.path.join(_CORPUS_OUT, name + ".docket.json"), encoding="utf-8"))
    d.pop("_provenance", None)
    d.pop("_residue", None)
    return d


def main():
    print("-- reference press (the contract's own gear) --")
    ref_group, ref_member = reference_dockets()

    lanes = {
        "dot_target": {
            "group_docket": ref_group,
            "members": {"appear": ref_member, "persist": persist_variant(ref_member)},
            "slots": {
                "member.id": "the family display name",
                "member.uid": "mint (one-time, randomizer)",
                "member.triggers.1.trigger.auranames.1": "the family rep spellId (string)",
                "member.load.class": "rekey the single multiselect key to the class token",
                "group.id": "the seat label: 'COA - <Spec> <bucket> (<scope>)'",
                "group.uid": "mint",
                "group.load.class": "rekey to the class token",
            },
        },
        "dot_multi": {
            "group_docket": corpus_docket("DOTS"),
            "members": {"default": corpus_docket("DOT")},
            "slots": {
                "member.triggers.1.trigger.auranames": "the class's DoT family rep-ids (the whole array)",
                "member.id": "seat-scoped name", "member.uid": "mint",
                "group.id": "the seat label", "group.uid": "mint",
                "member.load.class": "rekey to the class token (add if absent)",
            },
        },
        "pet": {
            "group_docket": corpus_docket("Pet_health_test"),
            "members": {"default": corpus_docket("Pet_health_spawner")},
            "slots": {
                "member.id": "seat-scoped name", "member.uid": "mint",
                "group.id": "the seat label", "group.uid": "mint",
                "_note": "custom Lua rides verbatim (addons-bench authored; the charter's lane)",
            },
        },
    }

    out = {"lanes": {}, "_provenance": {
        "pressed_by": "creator/picker/press_templates.py (Phase 2) - expand->fill->bounce, gate first",
        "sources": {
            "dot_target": "target_tracker.contract.json via populate.py (NECROMANCER Death; Blight reference)",
            "dot_multi": "corpus/planning/out/DOT(S).docket.json (multidot pattern, closure-stamped)",
            "pet": "corpus/planning/out/Pet_health_*.docket.json (guardian scaffold, closure-stamped)",
        },
        "fragments": {
            "appear": "the pressed default (aura2 matchesShowOn=showOnActive)",
            "persist": "matchesShowOn=showAlways + condition show==0 -> desaturate "
                       "(domain bufftrigger_2_progress_behavior_types; corpus-proven condition form)",
        },
    }}

    for lane, spec in lanes.items():
        print(f"-- {lane} --")
        entry = {"slots": spec["slots"], "members": {}}
        g = gate_or_die(spec["group_docket"], f"{lane}/group")
        entry["group"] = press_docket(g)
        print(f"    group   pressed: {len(entry['group'])} fields ({entry['group'].get('regionType')})")
        for frag, docket in spec["members"].items():
            m = gate_or_die(docket, f"{lane}/{frag}")
            entry["members"][frag] = press_docket(m)
            print(f"    {frag:8s} pressed: {len(entry['members'][frag])} fields "
                  f"({entry['members'][frag].get('regionType')})")
        out["lanes"][lane] = entry

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", encoding="utf-8", newline="\n") as f:
        json.dump(out, f, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
    n_members = sum(len(v["members"]) for v in out["lanes"].values())
    print(f"\ntemplates.json: {len(out['lanes'])} lanes, {n_members} member templates, "
          f"{os.path.getsize(OUT)/1000:.0f} KB")


if __name__ == "__main__":
    main()
