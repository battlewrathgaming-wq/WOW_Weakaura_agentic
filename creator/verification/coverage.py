"""
coverage.py - the VERIFICATION PACKET: one flat group whose members exercise the whole selectable surface.

The point is to FIND GAPS, not to celebrate the proven zone: every selectable region type, every trigger type,
some members 3 triggers deep with differing conditions. Failures are the product - each names a wall:
  - BLOCKED at the gate       -> an authoring error in THIS matrix (fix the row; the gate's note says how)
  - dies at canon/codec       -> a machine gap (fix the gear/map, or record the wall)
  - imports wrong in-game     -> a liveness/behaviour gap (harvest -> map -> gate tier, like spellIds/use_class)
Rows carry `expect`: "pass" or "wall:<reason>" once triaged - so verify stays re-runnable and honest as we go.

KNOWN boundary (recorded, not hidden): nested groups are unbuilt (bundle: FLAT only), so group/dynamicgroup can't
ride as members - the packet's own group covers dynamicgroup; `group` stays a named wall.

  py coverage.py          -> press all rows as dockets into Production/_authored/ (pid verification-coverage)
"""
import json
import os
import re
import sys

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.normpath(os.path.join(_THIS, "..", ".."))
AUTHORED = os.path.join(_ROOT, "Weak Auras", "engine", "Production", "_authored")
PID = "verification-coverage"

# corpus-real ids (Necromancer families - the gate validates ids against coa_spells)
BLIGHT, LICH, FDECAY, PLAGUE = "500217", "802132", "806324", "501940"

def A(unit="player", dt="HELPFUL", ids=None, own=True, **kw):
    """aura2 declare shorthand - the family-catch basis + extras."""
    d = {"unit": unit, "debuffType": dt, "ownOnly": own, "useName": True, "auranames": ids or [BLIGHT]}
    d.update(kw); return d

def T(ttype, event, declare):
    return {"type": ttype, "event": event, "declare": declare}

def C(trig, var, op, val, **changes):
    return {"check": {"trigger": trig, "variable": var, "op": op, "value": val}, "changes": changes}

# ---- THE MATRIX ------------------------------------------------------------------------------------------------
# (region, name, triggers, extra) - extra: display/subregions/conditions/activation/load
ROWS = [
 # -- icons: aura2 in depth --
 ("icon", "a2 player HELPFUL family baseline", [T("aura2", "Aura", A())], {}),
 ("icon", "a2 target HARMFUL showOnMissing desat", [T("aura2", "Aura", A("target", "HARMFUL", [FDECAY],
     use_matchesShowOn=True, matchesShowOn="showOnMissing"))], {"display": {"desaturate": True}}),
 ("icon", "a2 exact-id catch zoom", [T("aura2", "Aura", {"unit": "player", "debuffType": "HELPFUL",
     "useExactSpellId": True, "auraspellids": [LICH], "ownOnly": True})], {"display": {"zoom": 0.3, "keepAspectRatio": True}}),
 ("icon", "a2 BOTH debuffClass Magic color", [T("aura2", "Aura", A(dt="BOTH", use_debuffClass=True,
     debuffClass={"magic": True}))], {"display": {"color": [0.5, 0.5, 1, 1]}}),
 ("icon", "a2 stacks-gate + stacks text", [T("aura2", "Aura", A(useStacks=True, stacksOperator=">=", stacks="2"))],
     {"subregions": [{"type": "subtext", "text_text": "%s"}]}),
 ("icon", "a2 rem-gate + rem condition colorflip", [T("aura2", "Aura", A("target", "HARMFUL", [PLAGUE],
     useRem=True, remOperator="<", rem="5"))],
     {"conditions": [C(1, "expirationTime", "<", "3", color=[1, 0, 0, 1])]}),
 ("icon", "a2 showAlways + stacks condition + nudge", [T("aura2", "Aura", A(use_matchesShowOn=True,
     matchesShowOn="showAlways"))],
     {"conditions": [C(1, "stacks", ">=", "3", desaturate=False, xOffsetRelative=6)]}),
 ("icon", "a2 clones", [T("aura2", "Aura", A(ids=[BLIGHT], showClones=True))], {}),
 ("icon", "DEEP 3trig any: a2p+a2t+cooldown, per-trigger conditions",
     [T("aura2", "Aura", A()), T("aura2", "Aura", A("target", "HARMFUL", [FDECAY])),
      T("spell", "Cooldown Progress (Spell)", {"use_spellName": True, "spellName": LICH})],
     {"activation": {"disjunctive": "any"},
      "conditions": [C(2, "expirationTime", "<", "4", color=[1, 0.5, 0, 1]),
                     C(3, "onCooldown", "==", 1, desaturate=True)]}),
 ("icon", "spell Cooldown Progress solo inverse", [T("spell", "Cooldown Progress (Spell)",
     {"use_spellName": True, "spellName": LICH})], {"display": {"inverse": True}}),
 ("icon", "spell Action Usable", [T("spell", "Action Usable", {"use_spellName": True, "spellName": LICH})], {}),
 ("icon", "unit Conditions player", [T("unit", "Conditions", {"use_alwaystrue": True})], {}),
 ("icon", "item Item Count", [T("item", "Item Count", {"use_itemName": True, "itemName": "Hearthstone"})], {}),
 ("icon", "event Combat Events", [T("event", "Combat Events", {})], {}),
 ("icon", "combatlog spellId catch", [T("combatlog", "Combat Log",
     {"use_spellId": True, "spellId": [BLIGHT]})], {}),
     # FINDING: subeventPrefix/Suffix are NOT on the combatlog options surface (stored keys the options builder
     # never enumerates - the aura2-residue story's cousin). Harvest boundary recorded; spellId route used.
 ("icon", "custom status static-true", [T("custom", "Custom", {"custom_type": "status", "check": "update",
     "custom": "function() return true end"})], {}),
 ("icon", "addons GTFO High Damage", [T("addons", "GTFO", {"use_alertType": True, "alertType": "High Damage"})], {}),

 # -- bars --
 ("aurabar", "a2 baseline + icon LEFT", [T("aura2", "Aura", A())], {"display": {"icon": True, "icon_side": "LEFT"}}),
 ("aurabar", "a2 target inverse gradient", [T("aura2", "Aura", A("target", "HARMFUL", [PLAGUE]))],
     {"display": {"inverse": True, "enableGradient": True, "barColor2": [0, 1, 0, 1]}}),
 ("aurabar", "a2 rem-gate spark + barColor condition", [T("aura2", "Aura", A(ids=[BLIGHT], useRem=True,
     remOperator="<", rem="6"))],
     {"display": {"spark": True}, "conditions": [C(1, "expirationTime", "<", "3", barColor=[1, 0, 0, 1])]}),
 ("aurabar", "spell Cooldown Progress VERTICAL", [T("spell", "Cooldown Progress (Spell)",
     {"use_spellName": True, "spellName": LICH})], {"display": {"orientation": "VERTICAL"}}),
 ("aurabar", "DEEP 3trig all: a2+unit+usable, differing conditions",
     [T("aura2", "Aura", A()), T("unit", "Conditions", {"use_alwaystrue": True}),
      T("spell", "Action Usable", {"use_spellName": True, "spellName": LICH})],
     {"activation": {"disjunctive": "all"},
      "conditions": [C(1, "stacks", ">=", "2", barColor=[1, 0.8, 0, 1]),
                     C(3, "spellUsable", "==", 1, desaturate=False)]}),
 ("aurabar", "custom status customDuration", [T("custom", "Custom", {"custom_type": "status", "check": "update",
     "custom": "function() return true end", "customDuration": "function() return 10, GetTime()+10 end"})], {}),
 ("aurabar", "a2 + %p %n text sub", [T("aura2", "Aura", A())],
     {"subregions": [{"type": "subtext", "text_text": "%n %p"}]}),

 # -- the other selectable regions --
 ("text", "a2 -> displayText %n %p", [T("aura2", "Aura", A())], {"display": {"displayText": "%n %p"}}),
 ("text", "unit Character Stats readout", [T("unit", "Character Stats", {})],
     {"display": {"displayText": "haste %p"}}),
 ("texture", "a2 square shows-while-up + color condition", [T("aura2", "Aura", A())],
     {"conditions": [C(1, "stacks", ">=", "2", color=[0, 1, 0, 1])]}),
 ("texture", "spell Cooldown Ready flash-asset", [T("spell", "Cooldown Ready (Spell)",
     {"use_spellName": True, "spellName": LICH})], {}),
 ("progresstexture", "a2 radial", [T("aura2", "Aura", A())], {}),
 ("progresstexture", "spell Cooldown Progress radial", [T("spell", "Cooldown Progress (Spell)",
     {"use_spellName": True, "spellName": LICH})], {}),
 ("stopmotion", "a2 animated while active", [T("aura2", "Aura", A())], {}),
 ("model", "a2 3D flair while active", [T("aura2", "Aura", A())], {}),
 ("empty", "a2 logic-holder + combat load", [T("aura2", "Aura", A())],
     {"load": {"use_combat": True}}),

 # -- deliberate sentinels --
 ("empty", "MUST-NOT-LOAD use_never sentinel", [T("aura2", "Aura", A())], {"load": {"use_never": True}}),
 ("icon", "load: spellknown + all-COA-class multi", [T("aura2", "Aura", A())],
     {"load": {"use_class": False, "class": {"multi": {"NECROMANCER": True, "REAPER": True}},
               "use_spellknown": True, "spellknown": int(BLIGHT)}}),
 ("aurabar", "activation activeTriggerMode trigger-2 of 2",
     [T("aura2", "Aura", A()), T("aura2", "Aura", A("target", "HARMFUL", [FDECAY]))],
     {"activation": {"disjunctive": "any", "activeTriggerMode": 2}}),
]
# ------------------------------------------------------------------------------------------------------------------


def main():
    os.makedirs(AUTHORED, exist_ok=True)
    import glob
    for stale in glob.glob(os.path.join(AUTHORED, PID + "__*.docket.json")):
        os.unlink(stale)                                     # the press owns its pid's files - clean before writing
    group = {"pid": PID, "id": "VERIFICATION - coverage packet", "uid": "coaVerifCoverageGrp",
             "regionType": "dynamicgroup"}
    docs = [("GROUP", group)]
    for i, (region, name, triggers, extra) in enumerate(ROWS, 1):
        slug = re.sub(r"[^A-Za-z0-9]+", "_", name).strip("_")[:44]
        doc = {"pid": PID, "id": "V%02d %s | %s" % (i, region, name), "uid": "coaVerif%02d" % i,
               "regionType": region, "triggers": triggers}
        for k in ("display", "subregions", "conditions", "activation", "load"):
            if k in extra:
                doc[k] = extra[k]
        docs.append(("V%02d_%s" % (i, slug), doc))
    for fname, doc in docs:
        fp = os.path.join(AUTHORED, "%s__%s.docket.json" % (PID, fname))
        json.dump(doc, open(fp, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print("pressed %d dockets (1 group + %d members) -> _authored/ (pid %s)" % (len(docs), len(ROWS), PID))


if __name__ == "__main__":
    main()
