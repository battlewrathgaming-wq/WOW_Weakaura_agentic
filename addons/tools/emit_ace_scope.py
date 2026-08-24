# -*- coding: utf-8 -*-
r"""emit_ace_scope.py - what Ace3 IS on this client, and what of it we have hand-rolled.

    py addons\tools\emit_ace_scope.py

★★★ THE QUESTION IS BATTLEWRATH'S, 2026-08-24: *"Fully scope ace and see what it saves us from
developing."* ⟶ Two halves, and only the first is a survey:

    SUPPLY   every Ace3 module present anywhere in the client's AddOns, with its highest minor
             and how many addons carry it - the field's own answer to "which of these matter"
    DEMAND   for each module, whether OUR addons already do that job by hand - matched on the
             CALL that module replaces, never on the module's name

⚠⚠ THE DEMAND SIDE IS EVIDENCE, NOT A VERDICT. A grep for `RegisterEvent` says we handle events
ourselves; it does NOT say AceEvent would be better, and this tool never claims that. `a name is
not a use` cuts both ways: finding the call proves we do the work, and proves nothing about
whether the library should do it instead. **The judgement is the architect's; this is the basis.**

⚠ READ-ONLY. Prints; writes nothing.
"""
import re
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")

REPO = Path(__file__).resolve().parents[2]
CLIENT = Path(r"F:\games\Ascension_wow\resources\ascension-live\Interface\AddOns")
OURS = REPO / "addons"

# ★ What each module DOES, and the CALL SITE that betrays a hand-rolled version of it. The
# pattern is what our code would contain if we were doing that job ourselves.
# ⚠ `None` means "no honest single-call tell" - reported as unknown rather than guessed.
JOBS = [
    ("AceAddon-3.0",        "addon lifecycle: OnInitialize / OnEnable / module tree",
     r"ADDON_LOADED|PLAYER_LOGIN"),
    ("AceEvent-3.0",        "event registration and dispatch, per object",
     r":RegisterEvent\(|SetScript\(\"OnEvent\""),
    ("AceDB-3.0",           "SavedVariables with PROFILES, defaults, per-char/realm/class",
     r"SavedVariables|defaults\s*="),
    ("AceDBOptions-3.0",    "the profile options table you would otherwise write",
     None),
    ("AceConsole-3.0",      "slash commands and Print",
     r"SlashCmdList|SLASH_[A-Z]"),
    ("AceGUI-3.0",          "widget set + Flow/List/Fill layouts",
     r"CreateFrame\("),
    ("AceConfig-3.0",       "option TABLE -> built dialog",
     r"panespec|Spec\.zones"),
    ("AceConfigDialog-3.0", "renders an option table into AceGUI, incl. tabs",
     None),
    ("AceConfigRegistry-3.0", "validates option tables, notifies change",
     None),
    ("AceHook-3.0",         "safe hooking, unhook on disable",
     r"hooksecurefunc"),
    ("AceLocale-3.0",       "translation tables with a missing-key guard",
     r"L\[|locale"),
    ("AceSerializer-3.0",   "Lua value <-> string, for export and comms",
     r"serial|Serialize|Encode|Deflate"),
    ("AceComm-3.0",         "addon messages, chunked and reassembled",
     r"SendAddonMessage|CHAT_MSG_ADDON"),
    ("AceBucket-3.0",       "COALESCE a storm of events into one delayed call",
     r"bucket|coalesc"),
    ("AceTimer-3.0",        "named, cancellable, repeating timers",
     r"C_Timer|OnUpdate"),
    ("AceTab-3.0",          "tab completion in the chat box", None),
    ("CallbackHandler-1.0", "the callback bus every Ace module registers through",
     r"callback|:Fire\("),
    ("LibStub",             "library versioning", r"LibStub"),
    ("LibSharedMedia-3.0",  "user-chosen fonts/textures/sounds registry", None),
    ("LibDataBroker-1.1",   "the launcher/data-feed object", None),
    ("LibDBIcon-1.0",       "the minimap button", None),
    ("LibDualSpec-1.0",     "swap profile with talent spec", None),
    ("LibWindow-1.1",       "remember a window's position across resolutions", None),
    ("LibQTip-1.0",         "multi-column tooltips", None),
]

MAJOR = re.compile(r'["\']((?:Ace\w+-3\.0)|(?:Lib[\w]+-[\d.]+)|LibStub)["\']\s*,\s*([\d]+)')


def scan_client():
    """Which Ace3/Lib modules exist, at what highest minor, in how many addons."""
    found = {}
    if not CLIENT.exists():
        return found, 0
    dirs = [d for d in CLIENT.iterdir() if d.is_dir()]
    for d in dirs:
        seen = set()
        for lua in d.rglob("*.lua"):
            try:
                head = lua.read_text(encoding="utf-8", errors="ignore")[:4000]
            except OSError:
                continue
            for m in MAJOR.finditer(head):
                name, minor = m.group(1), int(m.group(2))
                # ⚠ Only the DECLARING file counts - a consumer's LibStub("X") call has no
                # minor and would otherwise inflate the count with every user.
                if "MAJOR" not in head[:m.start()][-120:] and "NewLibrary" not in head:
                    continue
                seen.add(name)
                e = found.setdefault(name, {"minor": 0, "addons": set()})
                e["minor"] = max(e["minor"], minor)
        for name in seen:
            found[name]["addons"].add(d.name)
    return found, len(dirs)


def scan_ours():
    """Which of those jobs our own addon code already does, by CALL not by name."""
    # ⚠⚠ OUR ADDONS ONLY, AND THE FIRST CUT DID NOT DO THIS. Globbing everything under
    # `addons/` swept in `landing/records/*.lua` - captured source from OTHER PEOPLE'S addons -
    # and reported `BronzeLFG.lua`, `MinionDps.lua` and a census dump as evidence that WE
    # hand-roll AceEvent. 552 files where we have a few dozen. ⟶ A scope that is too WIDE
    # produces confident wrong attributions exactly as readily as one that is too narrow.
    # ★ An addon is a directory with a `.toc`. That is the client's own definition, not ours.
    roots = sorted(p.parent for p in OURS.glob("*/*.toc"))
    files = [p for r in roots for p in r.rglob("*.lua") if "Libs" not in p.parts]
    blob = {}
    for p in files:
        try:
            blob[p] = p.read_text(encoding="utf-8", errors="ignore")
        except OSError:
            pass
    out = {}
    for name, _what, pat in JOBS:
        if not pat:
            out[name] = None
            continue
        rx = re.compile(pat, re.I)
        hits = {}
        for p, text in blob.items():
            n = len(rx.findall(text))
            if n:
                hits[p.relative_to(REPO).as_posix()] = n
        out[name] = hits
    return out, len(files)


def main():
    found, ndirs = scan_client()
    ours, nfiles = scan_ours()

    print(f"ACE3 ON THIS CLIENT   {ndirs} addon directories scanned in {CLIENT.name}")
    print(f"OUR CODE              {nfiles} .lua file(s) in addons that have a .toc (Libs excluded)")
    print(f"\n{'module':<24}{'minor':>6}{'addons':>8}   {'we do this job by hand?':<34} what it is")
    print("-" * 150)
    for name, what, pat in JOBS:
        f = found.get(name)
        minor = f["minor"] if f else 0
        n = len(f["addons"]) if f else 0
        h = ours.get(name)
        if h is None:
            mine = "- no single-call tell -"
        elif not h:
            mine = "no"
        else:
            top = sorted(h.items(), key=lambda kv: -kv[1])[:2]
            mine = "YES: " + ", ".join(f"{Path(k).name}({v})" for k, v in top)
        print(f"{name:<24}{minor if minor else '-':>6}{n if n else '-':>8}   {mine:<34} {what}")

    print("\n⚠ `addons` counts DECLARING copies, not users - a consumer's LibStub() call carries")
    print("  no minor and would inflate every row.")
    print("⚠⚠ A `YES` is evidence that we do the work, and NOTHING about whether the library")
    print("   should do it instead. That judgement is the architect's; this is the basis.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
