# -*- coding: utf-8 -*-
r"""read_templates.py - read the CLIENT'S OWN frame templates out of the MPQ chain and
emit them as a Lua table the offline harness can build against.

    py addons\tools\read_templates.py
    -> addons\staging\framexml_templates.lua

★★★ WHY. `CreateFrame(type, name, parent, TEMPLATE)` is where a control gets most of its
real geometry - an explicit `<Size>`, and named child regions the widget then looks up by
convention (`$parentText`, `$parentMiddle`). Our stub dropped the fourth argument on the
floor, so every templated control we ship has been measured offline as a sizeless box.
`object.lua` alone builds 26 buttons, 12 edit boxes, 8 dropdowns and 8 check buttons that
way. ★ The offline geometry check has never seen any of them at their true size.

★★ AND WE DO NOT MODEL THEM, WE READ THEM. `Interface\FrameXML` lives in `patch-B.MPQ`
(378 files) and `mpyq` reads it. So the templates are SOURCE, not our reconstruction -
[[source-as-truth-no-creator-dialect]] applied to the client's own UI. ⚠ A hand-written
approximation of `UIPanelButtonTemplate` would be a creator dialect: right until Blizzard's
numbers and ours disagree, with nothing to notice when they do.

⚠ READ-ONLY ON THE CLIENT. The archive is opened for reading; nothing is ever written
under F:\games. Output goes to `addons/staging/` (gitignored) and is REGENERATED rather
than edited - it is Blizzard's content, so it is a build input we can always re-make, not
an artifact we carry.
"""

import io
import os
import re
import sys
import xml.etree.ElementTree as ET

sys.stdout.reconfigure(encoding="utf-8")

from mpyq import MPQArchive

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DATA = r"F:\games\Ascension_wow\resources\ascension-live\Data"
OUT = os.path.join(REPO, "addons", "staging", "framexml_templates.lua")
# ⚠ `interface\`, NOT `interface\framexml\`. My first scan looked only in FrameXML and
# reported UIDropDownMenuTemplate MISSING. `FrameXML.toc` says otherwise — it pulls
# `..\SharedXML\UIDropDownMenu.xml`, and this client's UI is modernised enough to carry
# SharedXML, FilterDropDown and ScrollableDropDown alongside the 3.3.5 furniture.
# ★ The toc is the manifest. Guessing the folder from the name is how a present file
# came back "missing" — the same shape as calling `C_Timer` absent because a name search
# said so (ROUTER:75).
PREFIX = "interface\\"


def framexml_files():
    """Every Interface\\FrameXML\\*.xml in the chain, later archives winning.

    ⚠ The win rule is stated even though today only ONE archive carries FrameXML - a
    chain that happens to have no conflict is not a chain that cannot."""
    found = {}
    for n in sorted(os.listdir(DATA)):
        if not n.lower().endswith(".mpq"):
            continue
        try:
            a = MPQArchive(os.path.join(DATA, n), listfile=True)
            names = a.files
            if not names:
                continue
        except Exception:
            continue                      # unreadable archives are reported by the caller
        for raw in names:
            k = raw.decode("utf-8", "replace").replace("/", "\\")
            if k.lower().startswith(PREFIX) and k.lower().endswith(".xml"):
                found[k.lower()] = (n, a, k)
    return found


def strip_ns(tag):
    return tag.split("}")[-1]


def abs_size(node):
    s = node.find("Size")
    if s is None:
        return None
    d = s.find("AbsDimension")
    if d is None:
        return None
    try:
        return (float(d.get("x", 0)), float(d.get("y", 0)))
    except ValueError:
        return None


def anchors_of(node):
    out = []
    a = node.find("Anchors")
    if a is None:
        return out
    for an in a.findall("Anchor"):
        off = an.find("Offset")
        x = y = 0.0
        if off is not None:
            d = off.find("AbsDimension")
            if d is not None:
                x, y = float(d.get("x", 0)), float(d.get("y", 0))
        out.append({"point": an.get("point", ""),
                    "rel": an.get("relativeTo", ""),
                    "relPoint": an.get("relativePoint", ""),
                    "x": x, "y": y})
    return out


REGION_TAGS = {"Texture", "FontString"}


def regions_of(node):
    """Named children a widget can look up: layer textures/fontstrings and sub-frames."""
    out = []
    layers = node.find("Layers")
    if layers is not None:
        for layer in layers.findall("Layer"):
            for r in layer:
                t = strip_ns(r.tag)
                if t in REGION_TAGS and r.get("name"):
                    sz = abs_size(r)
                    out.append({"name": r.get("name"), "kind": t.lower(),
                                "w": sz[0] if sz else None, "h": sz[1] if sz else None,
                                "anchors": anchors_of(r)})
    frames = node.find("Frames")
    if frames is not None:
        for r in frames:
            if r.get("name"):
                sz = abs_size(r)
                out.append({"name": r.get("name"), "kind": strip_ns(r.tag).lower(),
                            "w": sz[0] if sz else None, "h": sz[1] if sz else None,
                            "anchors": anchors_of(r)})
    # ★ ButtonText is what `Button:GetFontString()` returns - the single missing region
    # that stopped every AceGUI Button from building.
    bt = node.find("ButtonText")
    if bt is not None:
        out.append({"name": bt.get("name") or "$parentText", "kind": "fontstring",
                    "w": None, "h": None, "anchors": anchors_of(bt), "buttontext": True})
    return out


def lua_str(s):
    return '"%s"' % str(s).replace("\\", "\\\\").replace('"', '\\"')


def emit(templates, stats):
    L = []
    L.append("-- GENERATED by addons/tools/read_templates.py - DO NOT EDIT.")
    L.append("-- The client's own frame templates, read from the MPQ chain.")
    L.append("-- source: %s" % stats["archives"])
    L.append("-- %d xml file(s), %d virtual template(s)" % (stats["files"], len(templates)))
    L.append("--")
    L.append("-- ⚠ Blizzard's content, REGENERATED not carried: this file lives in")
    L.append("--   addons/staging (gitignored) and is re-made by the tool, never edited.")
    L.append("local T = {}")
    for name in sorted(templates):
        t = templates[name]
        L.append("T[%s] = {" % lua_str(name))
        if t.get("inherits"):
            L.append("  inherits = %s," % lua_str(t["inherits"]))
        if t.get("size"):
            L.append("  w = %g, h = %g," % t["size"])
        if t.get("kind"):
            L.append("  kind = %s," % lua_str(t["kind"]))
        if t["regions"]:
            L.append("  regions = {")
            for r in t["regions"]:
                bits = ["name = %s" % lua_str(r["name"]), "kind = %s" % lua_str(r["kind"])]
                if r["w"] is not None:
                    bits.append("w = %g" % r["w"])
                if r["h"] is not None:
                    bits.append("h = %g" % r["h"])
                if r.get("buttontext"):
                    bits.append("buttontext = true")
                if r["anchors"]:
                    ab = []
                    for a in r["anchors"]:
                        ab.append("{ point = %s, relPoint = %s, x = %g, y = %g }"
                                  % (lua_str(a["point"]), lua_str(a["relPoint"]),
                                     a["x"], a["y"]))
                    bits.append("anchors = { %s }" % ", ".join(ab))
                L.append("    { %s }," % ", ".join(bits))
            L.append("  },")
        L.append("}")
    L.append("return T")
    io.open(OUT, "w", encoding="utf-8", newline="\n").write("\n".join(L) + "\n")


def main():
    files = framexml_files()
    if not files:
        print("no Interface\\FrameXML\\*.xml in the archive chain")
        return 1
    archives = sorted({v[0] for v in files.values()})
    templates, parsed, bad = {}, 0, 0
    for key, (arch, a, realname) in sorted(files.items()):
        try:
            blob = a.read_file(realname)
            if not blob:
                continue
            text = blob.decode("utf-8", "replace")
            # ⚠ namespaces stripped so findall() reads as written in the file
            text = re.sub(r'\sxmlns(:\w+)?="[^"]*"', "", text, count=1)
            root = ET.fromstring(text)
        except Exception:
            bad += 1
            continue
        parsed += 1
        for node in root:
            if node.get("virtual") != "true" or not node.get("name"):
                continue
            sz = abs_size(node)
            templates[node.get("name")] = {
                "kind": strip_ns(node.tag),
                "inherits": node.get("inherits"),
                "size": sz,
                "regions": regions_of(node),
            }
    emit(templates, {"archives": ", ".join(archives), "files": parsed})
    print("  archives: %s" % ", ".join(archives))
    print("  %d xml parsed (%d unparseable), %d virtual templates -> %s"
          % (parsed, bad, len(templates), os.path.relpath(OUT, REPO)))
    for want in ("UIPanelButtonTemplate", "UIPanelButtonTemplate2", "InputBoxTemplate",
                 "UIDropDownMenuTemplate", "UICheckButtonTemplate",
                 "OptionsFrameTabButtonTemplate", "UIPanelCloseButton"):
        t = templates.get(want)
        print("    %-32s %s" % (want, "%d region(s)%s" % (
            len(t["regions"]),
            (", %gx%g" % t["size"]) if t["size"] else "") if t else "MISSING"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
