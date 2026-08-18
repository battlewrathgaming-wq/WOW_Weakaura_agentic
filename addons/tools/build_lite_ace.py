# -*- coding: utf-8 -*-
r"""build_lite_ace.py - assemble the LITE Ace3 that Dungeon Run ships (A10.1b, P2).

    py addons\tools\build_lite_ace.py
    -> addons\COA_DungeonRun\Libs\...

★★★ IT IS A MERGE, NOT A COPY, and that is measured rather than preferred. r960 is the
base: it is the AceGUI revision this client's own working addons ship (rev 33), its whole
API surface is attested here, and modern-r1403's AceConfigDialog does not even LOAD
(line 589). ⚠ But r960's TabGroup calls the client's global
`PanelTemplates_TabResize(frame, 0, nil, width)` and THIS CLIENT'S signature is
`(tab, padding, absoluteSize, maxWidth, absoluteTextSize)` - modernised, so `width` lands
in the slot read as `maxWidth`. ★ modern-r1403 fixed exactly this by VENDORING the
function as a `local` in its own TabGroup instead of calling the global. So the base is
r960 and named files come from r1403, each recorded here with its reason.

⚠ THE WIDGET SET IS NOT CHOSEN BY READING. A10.1b names twelve; `AceConfigDialog`
constructs SEVENTEEN by literal name, including `Frame` - its DEFAULT container. Rather
than argue from a grep, `run_ace_probe.py` drives the real option table through the
shipped set and reports every `Create("X")` that fails, and that list is the answer.
"""

import io
import os
import shutil
import sys

sys.stdout.reconfigure(encoding="utf-8")

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
BASE = os.path.join(REPO, "dependencies", "Ace3", "wotlk-r960")
MODERN = os.path.join(REPO, "dependencies", "Ace3", "modern-r1403")
OUT = os.path.join(REPO, "addons", "COA_DungeonRun", "Libs")

CORE = [
    "LibStub/LibStub.lua",
    "CallbackHandler-1.0/CallbackHandler-1.0.lua",
    "AceGUI-3.0/AceGUI-3.0.lua",
    "AceConfig-3.0/AceConfigRegistry-3.0/AceConfigRegistry-3.0.lua",
    "AceConfig-3.0/AceConfigDialog-3.0/AceConfigDialog-3.0.lua",
]

# A10.1b's twelve, by name.
WIDGETS = [
    "AceGUIContainer-TabGroup", "AceGUIContainer-SimpleGroup",
    "AceGUIContainer-InlineGroup", "AceGUIContainer-Window",
    # ★ ADDED BY MEASUREMENT, not by reading. A10.1b's twelve omit `Frame`, and
    # AceConfigDialog:Open creates one as its DEFAULT CONTAINER
    # (AceConfigDialog-3.0.lua:1798, `f = gui:Create("Frame")`). Without it the
    # probe died on `attempt to index local 'f'` - the shipped set naming its own
    # gap. ⚠ Each addition here is justified by a NAMED failure; nothing is added
    # speculatively, so the set stays minimal and every file can say why it is here.
    "AceGUIContainer-Frame",
    "AceGUIWidget-Label", "AceGUIWidget-Heading", "AceGUIWidget-Button",
    "AceGUIWidget-EditBox", "AceGUIWidget-CheckBox",
    "AceGUIWidget-DropDown", "AceGUIWidget-DropDown-Items",
    "AceGUIWidget-Slider",
]

# ★ FROM r1403, WITH ITS REASON. Nothing lands here without one.
FROM_MODERN = {
    # ★★ EMPTY, AND THE ATTEMPT IS THE FINDING. TabGroup was taken from r1403 because
    # r960's calls the client's `PanelTemplates_TabResize` global with the 3.3.5 argument
    # order, while this client's signature is modernised — `width` lands in the slot read
    # as `maxWidth`. r1403 vendors that function as a `local`, which looked like the
    # field's own answer to the same divergence.
    #
    # ⚠ IT IS NOT. r1403's TabGroup then wants retail-era tab FIELDS
    # (`tab.HighlightTexture`, TabGroup.lua:288) that this client's
    # OptionsFrameTabButtonTemplate does not provide. So BOTH FAIL, at opposite ends:
    # r960 against the client's modernised FUNCTION, r1403 against its un-modernised
    # FRAMES.
    #
    # ★ SO TABGROUP IS THE ONE FILE WHERE THE LITE BUILD STOPS BEING A MERGE AND BECOMES
    # OURS — r960's widget with a TabResize written to THIS client's signature, which is
    # read from the archive rather than guessed. ⚠ Left unfixed and LOUD rather than
    # half-swapped: a file taken from r1403 "because it is newer" would carry a reason
    # measurement had already refuted.
}


def main():
    if os.path.isdir(OUT):
        shutil.rmtree(OUT)

    manifest, taken = [], {"r960": 0, "r1403": 0}

    def take(rel, dest_rel=None):
        src_root, tag = BASE, "r960"
        if rel in FROM_MODERN:
            src_root, tag = MODERN, "r1403"
        src = os.path.join(src_root, rel.replace("/", os.sep))
        if not os.path.isfile(src):
            print("  MISSING in %s: %s" % (tag, rel))
            return False
        dst = os.path.join(OUT, (dest_rel or rel).replace("/", os.sep))
        d = os.path.dirname(dst)
        if not os.path.isdir(d):
            os.makedirs(d)
        shutil.copy2(src, dst)
        taken[tag] += 1
        manifest.append((dest_rel or rel, tag, FROM_MODERN.get(rel, "")))
        return True

    for rel in CORE:
        take(rel)
    for w in WIDGETS:
        take("AceGUI-3.0/widgets/%s.lua" % w)

    # ⚠ The licence travels with the code. Not optional and not a formality.
    for lic in ("LICENSE.txt",):
        src = os.path.join(BASE, lic)
        if os.path.isfile(src):
            shutil.copy2(src, os.path.join(OUT, lic))
            manifest.append((lic, "r960", "the BSD licence travels with the code"))

    lines = [
        "# Dungeon Run's LITE Ace3 - GENERATED by addons/tools/build_lite_ace.py.",
        "# Do not edit these files; change the tool and re-run.",
        "#",
        "# base: dependencies/Ace3/wotlk-r960 (AceGUI-3.0 rev 33 - the revision this",
        "#       client's own working addons ship). Named files from modern-r1403 carry",
        "#       their reason; nothing lands from there without one.",
        "#",
        "# file\tfrom\twhy (only when not the base)",
    ]
    for rel, tag, why in manifest:
        lines.append("%s\t%s\t%s" % (rel, tag, why))
    io.open(os.path.join(OUT, "MANIFEST.txt"), "w", encoding="utf-8",
            newline="\n").write("\n".join(lines) + "\n")

    print("  %d file(s) -> addons/COA_DungeonRun/Libs  (r960 %d · r1403 %d)"
          % (taken["r960"] + taken["r1403"], taken["r960"], taken["r1403"]))
    for rel, tag, why in manifest:
        if tag == "r1403":
            print("    ! %s  <- r1403" % rel)
    return 0


if __name__ == "__main__":
    sys.exit(main())
