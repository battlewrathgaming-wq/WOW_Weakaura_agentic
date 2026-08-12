"""emit_addon_census.py - hold OUR addons to the standard we hold theirs to.

We built `COA_DevDump/task_callwitness.lua` because Libellus Leti had no
self-reporting: "a witness we do not have". Answering "which function costs
frames?" for someone else's addon took a purpose-built instrument, four capture
arms and a run sheet. We then had no witness for our own code either.

This is it - and it is a FILE YOU READ, not an instrument you run.

Three questions, and the second is why it exists:

  1. WHAT DO WE DEFINE?   every function, per addon, per file
  2. WHAT DOES IT COST?   every OnUpdate, timer, event and hook - i.e. every
                          point our code runs without the user asking
  3. WHERE DO WE TOUCH THE CLIENT?
                          PULL - client API we read
                          PUSH - client state we write, frames we hook

OUTPUT - per addon AND a bench roll-up, so inspecting ONE addon is never a trip
through all of them:

    addons/maps/addons/
      frame_cost.md              bench roll-up: is ANYTHING costing frames?
      addons.census.json         machine copy, all residents
      <Addon>/frame_cost.md      that addon alone
      <Addon>/routes.md          its functions, and what it pulls/pushes

The emitter ALWAYS writes everything. `--addon` filters what is PRINTED, never
what is written: a flag that emits a partial census over a whole one leaves a
file that lies about the bench, and this tool exists to be trusted at a glance.

The resident list comes from deploy.py's MANIFEST - the ONE authority on who
lives here. A second hand-kept list drifts, and menu.bat's did, twice, silently.

Usage:
    py addons\\tools\\emit_addon_census.py
    py addons\\tools\\emit_addon_census.py --addon COA_Landmarks   # print filter
"""
import argparse
import json
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ADDONS = HERE.parent
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
SCRIPT = re.compile(r'SetScript\(\s*"(\w+)"')
# SetScript("OnUpdate", nil) is a CLEAR, not a second handler. Counting both as
# handlers inflated the bench total from 13 to 24 on the first run - a
# plausible-looking number that was simply wrong.
SCRIPT_SET = re.compile(r'SetScript\(\s*"(\w+)"\s*,\s*(nil)?')
HOOKSCRIPT = re.compile(r'HookScript\(\s*"(\w+)"')
EVENT = re.compile(r'RegisterEvent\(\s*"(\w+)"')
SECUREHOOK = re.compile(r'hooksecurefunc\(\s*(?:_G\s*,\s*)?["\']?([\w.]*)')
TIMER = re.compile(r'\b(Timer\.After|Timer\.NewTicker|C_Timer\.\w+)\b')
# A LEAD, never a verdict: a throttled OnUpdate has to accumulate somewhere.
# No accumulator in the file is a reason to LOOK, not a finding.
THROTTLE = re.compile(r'\b(elapsed|dt)\b|GetTime\(\)\s*[+<>]|acc\s*=')

# --- where we TOUCH the client (named, never inferred) ----------------
PUSH = re.compile(
    r'\b(SetCVar|C_CVar\.Set\w+|SuperTrackerUtil\.\w+|C_SuperTrack\.\w+'
    r'|ShowUIPanel|HideUIPanel|SetMapToCurrentZone|SetMapByID'
    r'|StaticPopup_Show|PlaySound)\b')
PULL = re.compile(
    r'\b(GetCurrentPlayerPosition|GetPlayerMapPosition|GetRealZoneText|GetSubZoneText'
    r'|GetCurrentMapContinent|GetCurrentMapZone|GetMapInfo|UnitName|UnitClass|UnitIsGhost'
    r'|GetRealmName|GetTime|GetAddOnMetadata|GetQuestLogTitle|GetQuestLogSelection'
    r'|C_CVar\.Get\w+|GetCVar|AtlasInfo|GetLocale)\b')

STRIP_COMMENT = re.compile(r'^\s*--')

LEGEND = [
    "**Lifetime is arithmetic: `installs − clears`.** **transient** = every handler is torn "
    "down again, so it runs only while something is happening (a drag, a running session "
    "task). **PERSISTENT** = none are, so they run for as long as the addon is loaded — that "
    "is where a cost would live. **MIXED** = both in one file, which a boolean hid on the "
    "first pass.",
    "",
    "**`throttle?` is a LEAD, not a verdict.** It reports whether the file contains an "
    "accumulator pattern at all. **`no` means go and look** — it does not mean the handler is "
    "unthrottled. The parent `README.md` records what the first run flagged and why every one "
    "of it was correct-by-design.",
    "",
]


def scan(path: Path):
    """Comment-only lines are stripped, so DOCUMENTING a pattern is never
    mistaken for USING one - this file's own docstring would otherwise
    register as a pile of hooks."""
    raw = path.read_text(encoding="utf-8", errors="replace")
    code = "\n".join(l for l in raw.splitlines() if not STRIP_COMMENT.match(l))

    funcs = []
    for pat, kind in FUNC:
        for m in pat.finditer(code):
            funcs.append({"name": ".".join(g for g in m.groups() if g),
                          "kind": kind,
                          "line": raw[:raw.find(m.group(0))].count("\n") + 1})

    installs = clears = 0
    for sname, isnil in SCRIPT_SET.findall(code):
        if sname == "OnUpdate":
            if isnil:
                clears += 1
            else:
                installs += 1

    return {
        "functions": sorted(funcs, key=lambda f: f["line"]),
        "onupdate": installs,
        "onupdate_clears": clears,
        # installs - clears = how many are never torn down IN THIS FILE. A file
        # can hold both kinds at once, so a boolean here hid two persistent
        # animators inside MancerLedger/minimap.lua on the first pass.
        "onupdate_persistent": max(0, installs - clears),
        "throttle_pattern": bool(THROTTLE.search(code)),
        "scripts": sorted(set(SCRIPT.findall(code))),
        "hookscripts": sorted(set(HOOKSCRIPT.findall(code))),
        "events": sorted(set(EVENT.findall(code))),
        "securehooks": sorted({h for h in SECUREHOOK.findall(code) if h}),
        "timers": sorted(set(TIMER.findall(code))),
        "push": sorted(set(PUSH.findall(code))),
        "pull": sorted(set(PULL.findall(code))),
    }


def lifetime(d):
    pers, total = d["onupdate_persistent"], d["onupdate"]
    if pers == 0:
        return "transient", pers
    if pers == total:
        return "**PERSISTENT**", pers
    return f"**MIXED** — {pers} persistent", pers


def _rows(scope, wide, key, fmt):
    """One row per file that has anything for `key`. `wide` prefixes the addon
    name - the roll-up needs it, a per-addon page does not."""
    out = []
    for name, files in scope.items():
        for fn, d in files.items():
            if d[key]:
                cells = [f"`{fn}`", fmt(d[key])]
                if wide:
                    cells.insert(0, name)
                out.append("| " + " | ".join(cells) + " |")
    return out


def _section(title, scope, wide, key, fmt, note=None):
    L = [f"## {title}", ""]
    if note:
        L += [note, ""]
    L += ["| Addon | File | Detail |" if wide else "| File | Detail |",
          "|---|---|---|" if wide else "|---|---|"]
    rows = _rows(scope, wide, key, fmt)
    L += rows or ["| " + " | ".join(["—"] * (3 if wide else 2)) + " |"]
    L.append("")
    return L


def frame_cost(scope, wide, title):
    head = ("| Addon | File | Installs | Clears | Lifetime | throttle? |\n"
            "|---|---|---|---|---|---|") if wide else (
           "| File | Installs | Clears | Lifetime | throttle? |\n"
           "|---|---|---|---|---|")
    rows, total, pers_total = [], 0, 0
    for name, files in scope.items():
        for fn, d in files.items():
            if not d["onupdate"]:
                continue
            life, pers = lifetime(d)
            total += d["onupdate"]
            pers_total += pers
            cells = [f"`{fn}`", str(d["onupdate"]), str(d["onupdate_clears"]), life,
                     "yes" if d["throttle_pattern"] else "**no — look**"]
            if wide:
                cells.insert(0, name)
            rows.append("| " + " | ".join(cells) + " |")
    if not rows:
        rows = ["| " + " | ".join(["—"] * (6 if wide else 5)) + " |"]

    L = [f"# {title}", "",
         "_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._", "",
         "**Read the OnUpdate table first.** It is the only kind of entry that runs *every "
         "frame*; everything below it fires when something happens.", ""] + LEGEND
    L += ["## ★ OnUpdate — runs every frame", "", head] + rows
    L += ["", f"**{total} handler(s) installed; {pers_total} PERSISTENT.** The persistent ones "
              "are the whole point of this page.", ""]
    L += _section("Timers", scope, wide, "timers", lambda v: ", ".join(v))
    L += _section("Events we listen for", scope, wide, "events", lambda v: ", ".join(v))
    L += _section("★ Hooks — hooksecurefunc", scope, wide, "securehooks",
                  lambda v: ", ".join("`%s`" % x for x in v),
                  note="_The highest-risk column: a hook runs inside someone else's flow._")
    L += _section("★ Hooks — HookScript on frames we do not own", scope, wide, "hookscripts",
                  lambda v: ", ".join("`%s`" % x for x in v),
                  note="_Anyone else doing the same can clobber ours, and silently._")
    return "\n".join(L)


def routes(name, files):
    nf = sum(len(f["functions"]) for f in files.values())
    pers = sum(f["onupdate_persistent"] for f in files.values())
    L = [f"# {name} — what it defines, and what it touches", "",
         "_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._", "",
         f"_{len(files)} file(s) · {nf} function(s) · **{pers} persistent OnUpdate "
         f"handler(s)** — see `frame_cost.md` beside this file._", ""]
    for fn, d in files.items():
        bits = []
        if d["onupdate"]:
            bits.append("**OnUpdate ×%d** (%d persistent)"
                        % (d["onupdate"], d["onupdate_persistent"]))
        for k, lbl in (("events", "events"), ("securehooks", "hooks"),
                       ("hookscripts", "hookscript"), ("timers", "timers")):
            if d[k]:
                bits.append(f"{lbl}: {', '.join(d[k])}")
        L.append(f"## `{fn}`" + ("  —  " + " · ".join(bits) if bits else ""))
        L.append("")
        if d["pull"]:
            L.append("**pulls:** " + ", ".join("`%s`" % p for p in d["pull"]))
        if d["push"]:
            L.append("**pushes:** " + ", ".join("`%s`" % p for p in d["push"]))
        if d["pull"] or d["push"]:
            L.append("")
        for f in d["functions"]:
            L.append(f"- `{f['name']}` *(:{f['line']}, {f['kind']})*")
        L.append("")
    return "\n".join(L)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--addon", help="print only this resident (everything is still written)")
    a = ap.parse_args()
    if a.addon and a.addon not in MANIFEST:
        sys.exit(f"'{a.addon}' is not a resident. Residents: {', '.join(MANIFEST)}")

    census = {}
    for name in MANIFEST:                       # ALWAYS every resident
        folder = ADDONS / name
        if folder.is_dir():
            census[name] = {lua.name: scan(lua) for lua in sorted(folder.glob("*.lua"))}

    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "addons.census.json").write_text(json.dumps(census, indent=1), encoding="utf-8")
    (OUT / "frame_cost.md").write_text(
        frame_cost(census, True, "Frame cost — the whole bench"), encoding="utf-8")

    for name, files in census.items():
        d = OUT / name
        d.mkdir(exist_ok=True)
        (d / "frame_cost.md").write_text(
            frame_cost({name: files}, False, f"Frame cost — {name}"), encoding="utf-8")
        (d / "routes.md").write_text(routes(name, files), encoding="utf-8")

    print(f"wrote {OUT}")
    show = {a.addon: census[a.addon]} if a.addon else census
    for name, files in show.items():
        nf = sum(len(f["functions"]) for f in files.values())
        pers = sum(f["onupdate_persistent"] for f in files.values())
        flag = "   <- unthrottled-looking handler, look" if any(
            f["onupdate"] and not f["throttle_pattern"] for f in files.values()) else ""
        print(f"  {name:<26} {len(files):>2} file(s)  {nf:>3} fn  "
              f"{pers} persistent OnUpdate{flag}")


if __name__ == "__main__":
    main()
