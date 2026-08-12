"""emit_addon_census.py - hold OUR addons to the standard we hold theirs to.

We built `task_callwitness` because Libellus Leti had no self-reporting: "a
witness we do not have". We then had none for our own code either. This is the
standing, emitted answer - a fact basis for what our addons DEFINE, what they
COST, and where they touch the client.

Three questions, and the second is the one that matters:

  1. WHAT DO WE DEFINE?     every function, per addon, per file
  2. WHAT DOES IT COST?     every OnUpdate, timer, event and hook - i.e. every
                            point our code runs without the user asking
  3. WHERE DO WE TOUCH THE CLIENT?
                            PULL  - client API we read
                            PUSH  - client state we write, and frames we hook

Question 2 is why this exists. When the Mancer stutter needed "which function
costs frames", answering it took a purpose-built instrument. For our own code
that should be a file you read.

Emitted, never hand-edited. The resident list comes from deploy.py's MANIFEST -
the ONE authority on who lives here - because a hand-kept second list drifts,
and menu.bat's did.

INPUT  : addons/<resident>/*.lua
OUTPUT : addons/maps/addons/  (addons.census.json + addons.routes.md + frame_cost.md)

Usage:
    py addons\\tools\\emit_addon_census.py
    py addons\\tools\\emit_addon_census.py --addon COA_Landmarks
"""
import argparse
import json
import re
import sys
from collections import defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
ADDONS = HERE.parent
ROOT = ADDONS.parent
OUT = ADDONS / "maps" / "addons"

sys.path.insert(0, str(ADDONS))
from deploy import MANIFEST                      # noqa: E402 - the one authority

# --- what we DEFINE ---------------------------------------------------
FUNC = [
    (re.compile(r'^\s*function\s+([\w.:]+)\s*\(', re.M),        "function"),
    (re.compile(r'^\s*local\s+function\s+(\w+)\s*\(', re.M),    "local"),
    (re.compile(r'^\s*(\w+)\.(\w+)\s*=\s*function\s*\(', re.M), "assigned"),
]

# --- what it COSTS ----------------------------------------------------
# OnUpdate is the only one that runs EVERY FRAME. It is called out separately
# everywhere below, because it is the only entry that can cost a stutter on its
# own - everything else fires when something happens.
SCRIPT = re.compile(r'SetScript\(\s*"(\w+)"')
# SetScript("OnUpdate", nil) is a CLEAR, not a second handler. Counting both
# as handlers inflated the bench total from 13 to 24 on the first run - a
# plausible-looking number that was simply wrong, and exactly the shape of
# error this whole bench keeps catching.
SCRIPT_SET = re.compile(r'SetScript\(\s*"(\w+)"\s*,\s*(nil)?')
# A LEAD, never a verdict: a throttled OnUpdate has to accumulate somewhere.
# No accumulator in the file is a reason to LOOK, not a finding.
THROTTLE = re.compile(r'\b(elapsed|dt)\b|GetTime\(\)\s*[+<>]|acc\s*=')
HOOKSCRIPT = re.compile(r'HookScript\(\s*"(\w+)"')
EVENT = re.compile(r'RegisterEvent\(\s*"(\w+)"')
SECUREHOOK = re.compile(r'hooksecurefunc\(\s*(?:_G\s*,\s*)?["\']?([\w.]*)')
TIMER = re.compile(r'\b(Timer\.After|Timer\.NewTicker|C_Timer\.\w+)\b')

# --- where we TOUCH the client ---------------------------------------
# PUSH: writes that leave our own tables. Deliberately narrow and named - a
# broad guess here would produce noise nobody reads.
PUSH = re.compile(
    r'\b(SetCVar|C_CVar\.Set\w+|SuperTrackerUtil\.\w+|C_SuperTrack\.\w+'
    r'|ShowUIPanel|HideUIPanel|SetMapToCurrentZone|SetMapByID'
    r'|StaticPopup_Show|PlaySound)\b')
# PULL: reads. Same rule - named, not inferred.
PULL = re.compile(
    r'\b(GetCurrentPlayerPosition|GetPlayerMapPosition|GetRealZoneText|GetSubZoneText'
    r'|GetCurrentMapContinent|GetCurrentMapZone|GetMapInfo|UnitName|UnitClass|UnitIsGhost'
    r'|GetRealmName|GetTime|GetAddOnMetadata|GetQuestLogTitle|GetQuestLogSelection'
    r'|C_CVar\.Get\w+|GetCVar|AtlasInfo|GetLocale)\b')

STRIP_COMMENT = re.compile(r'^\s*--')


def scan(path: Path):
    """Read a lua file, ignoring comment-only lines so documentation of a
    pattern is never mistaken for a use of it."""
    raw = path.read_text(encoding="utf-8", errors="replace")
    code = "\n".join(l for l in raw.splitlines() if not STRIP_COMMENT.match(l))

    funcs = []
    for pat, kind in FUNC:
        for m in pat.finditer(code):
            name = ".".join(g for g in m.groups() if g)
            funcs.append({"name": name, "kind": kind,
                          "line": raw[:raw.find(m.group(0))].count("\n") + 1})

    scripts = SCRIPT.findall(code)
    installs = clears = 0
    for sname, isnil in SCRIPT_SET.findall(code):
        if sname != "OnUpdate":
            continue
        if isnil:
            clears += 1
        else:
            installs += 1

    return {
        "functions": sorted(funcs, key=lambda f: f["line"]),
        "onupdate": installs,
        "onupdate_clears": clears,
        # installs - clears = how many are never torn down IN THIS FILE. A file
        # can hold both kinds at once (MancerLedger/minimap.lua has a balanced
        # drag pair AND two persistent animators), so a boolean here reported
        # that file as "transient" and hid two frame-cost handlers.
        "onupdate_persistent": max(0, installs - clears),
        "onupdate_transient": bool(installs and clears),
        "throttle_pattern": bool(THROTTLE.search(code)),
        "scripts": sorted(set(scripts)),
        "hookscripts": sorted(set(HOOKSCRIPT.findall(code))),
        "events": sorted(set(EVENT.findall(code))),
        "securehooks": sorted({h for h in SECUREHOOK.findall(code) if h}),
        "timers": sorted(set(TIMER.findall(code))),
        "push": sorted(set(PUSH.findall(code))),
        "pull": sorted(set(PULL.findall(code))),
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--addon", help="only this resident")
    a = ap.parse_args()

    names = [a.addon] if a.addon else list(MANIFEST)
    if a.addon and a.addon not in MANIFEST:
        sys.exit(f"'{a.addon}' is not a resident. Residents: {', '.join(MANIFEST)}")

    census = {}
    for name in names:
        folder = ADDONS / name
        if not folder.is_dir():
            print(f"  skip {name} - no folder")
            continue
        files = {}
        for lua in sorted(folder.glob("*.lua")):
            files[lua.name] = scan(lua)
        census[name] = files

    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "addons.census.json").write_text(
        json.dumps(census, indent=1), encoding="utf-8")

    # ---- the routes file: per addon, what it defines and touches ----
    L = ["# Addon census — what OUR addons define, cost, and touch", "",
         "_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._", "",
         "We built `task_callwitness` because someone else's addon had no "
         "self-reporting. This is ours. **`frame_cost.md` is the half that "
         "matters** — it is the file the Mancer stutter investigation wished "
         "existed for the addon it was chasing.", ""]
    for name, files in census.items():
        nf = sum(len(f["functions"]) for f in files.values())
        nu = sum(f["onupdate"] for f in files.values())
        L.append(f"## {name}")
        L.append(f"_{len(files)} file(s) · {nf} function(s) · "
                 f"**{nu} OnUpdate handler(s)**_")
        L.append("")
        for fn, d in files.items():
            bits = []
            if d["onupdate"]:
                pers = d.get("onupdate_persistent", d["onupdate"])
                bits.append("**OnUpdate ×%d** (%d persistent)" % (d["onupdate"], pers))
            for k, lbl in (("events", "events"), ("securehooks", "hooks"),
                           ("hookscripts", "hookscript"), ("timers", "timers")):
                if d[k]:
                    bits.append(f"{lbl}: {', '.join(d[k])}")
            L.append(f"### `{fn}`" + ("  —  " + " · ".join(bits) if bits else ""))
            if d["functions"]:
                L.append("")
                for f in d["functions"]:
                    L.append(f"- `{f['name']}` *(:{f['line']}, {f['kind']})*")
            if d["pull"]:
                L.append(f"\n**pulls:** {', '.join('`%s`' % p for p in d['pull'])}")
            if d["push"]:
                L.append(f"\n**pushes:** {', '.join('`%s`' % p for p in d['push'])}")
            L.append("")
    (OUT / "addons.routes.md").write_text("\n".join(L), encoding="utf-8")

    # ---- the one that matters ----
    C = ["# Frame cost — every point our code runs without being asked", "",
         "_Emitted by `addons/tools/emit_addon_census.py`._", "",
         "**Read the OnUpdate table first.** It is the only kind of entry that "
         "runs *every frame*; everything below it fires when something happens. "
         "If one of our addons is ever suspected of a stutter, this is the "
         "first page — the answer that `task_callwitness` had to be built to "
         "get for somebody else's code.", "",
         "## ★ OnUpdate — runs every frame", "",
         "**Lifetime is arithmetic: `installs - clears`.** **transient** = every handler is "
         "torn down again, so it runs only while something is happening (a drag, a running "
         "session task). **PERSISTENT** = none are, so they run for as long as the addon is "
         "loaded — that is where a cost would live. **MIXED** = both, in one file, which a "
         "boolean would have hidden.", "",
         "**throttle?** is a LEAD, not a verdict — it reports whether the file contains an "
         "accumulator pattern at all. `no` means go and look; it does not mean the handler "
         "is unthrottled.", "",
         "| Addon | File | Installs | Clears | Lifetime | throttle? |",
         "|---|---|---|---|---|---|"]
    total = persistent = 0
    for name, files in census.items():
        for fn, d in files.items():
            if d["onupdate"]:
                total += d["onupdate"]
                pers = d.get("onupdate_persistent", d["onupdate"])
                persistent += pers
                if pers == 0:
                    life = "transient"
                elif pers == d["onupdate"]:
                    life = "**PERSISTENT**"
                else:
                    life = f"**MIXED** — {pers} persistent"
                thr = "yes" if d.get("throttle_pattern") else "**no — look**"
                C.append(f"| {name} | `{fn}` | {d['onupdate']} | "
                         f"{d.get('onupdate_clears', 0)} | {life} | {thr} |")
    if total == 0:
        C.append("| — | *none* | 0 | 0 | — | — |")
    C += ["", f"**{total} handler(s) installed across the bench; {persistent} PERSISTENT.** "
              "The persistent ones are the whole point of this page.", "",
          "## Timers", "", "| Addon | File | Timers |", "|---|---|---|"]
    any_t = False
    for name, files in census.items():
        for fn, d in files.items():
            if d["timers"]:
                any_t = True
                C.append(f"| {name} | `{fn}` | {', '.join(d['timers'])} |")
    if not any_t:
        C.append("| — | *none* | — |")

    C += ["", "## Events we listen for", "", "| Addon | File | Events |", "|---|---|---|"]
    for name, files in census.items():
        for fn, d in files.items():
            if d["events"]:
                C.append(f"| {name} | `{fn}` | {', '.join(d['events'])} |")

    C += ["", "## ★ Hooks — where we attach to code we do not own", "",
          "_The highest-risk column. A hook runs inside someone else's flow, and "
          "a hook on a frame we did not create can be clobbered by anyone else "
          "who does the same._", "",
          "| Addon | File | Kind | Target |", "|---|---|---|---|"]
    any_h = False
    for name, files in census.items():
        for fn, d in files.items():
            for h in d["securehooks"]:
                any_h = True
                C.append(f"| {name} | `{fn}` | hooksecurefunc | `{h}` |")
            for h in d["hookscripts"]:
                any_h = True
                C.append(f"| {name} | `{fn}` | HookScript | `{h}` |")
    if not any_h:
        C.append("| — | *none* | — | — |")
    (OUT / "frame_cost.md").write_text("\n".join(C), encoding="utf-8")

    print(f"wrote {OUT}")
    print(f"  {len(census)} resident(s) · "
          f"{sum(sum(len(f['functions']) for f in v.values()) for v in census.values())} function(s) · "
          f"{total} OnUpdate handler(s)")


if __name__ == "__main__":
    main()
