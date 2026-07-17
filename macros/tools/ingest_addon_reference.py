r"""
ingest_addon_reference.py - ingest the installed MACRO ADDONS as a reference source.

reference/ IS NOT basis/. Same rule as the wikis: admissible as a QUESTION source, never
as a fact source - the probe adjudicates.

STANDING (Battlewrath, 2026-07-17): "they aren't verified as true, but they might frame
the validation better." Downloaded != working. An addon SHIPPING a macro string is
evidence its author BELIEVED it works on their target client - one notch stronger than a
wiki (it is code, aimed at a client) and still not proof.

  Asc_MacroBank      Author "Odlaw, Xan(Ascension Updates)", Interface 30300. MAINTAINED
                     FOR THIS SERVER, so its assumptions are aimed at CoA specifically.
  SuperDuperMacro    Interface 30300, retail-WotLK-derived. Its MacroInterpreter.lua says
                     "adapted from ChatFrame.lua" and mirrors SecureCmdList - but only the
                     8 commands that YIELD A SPELL/ITEM (it needs the icon), NOT the
                     command surface. It is not a mirror to diff against; treating it as
                     one produced a bogus 41-command "delta" that was scope, not finding.

WHAT THEY ACTUALLY CORROBORATE - the C wall, independently and strongly:
SuperDuperMacro's whole job is interpreting macros, and its interpreter STILL calls
SecureCmdOptionParse rather than reimplementing conditionals. An author who NEEDED the
vocabulary in Lua could not get it either. That is independent support for the central
finding: the vocabulary is C-side and unreachable from source.

Reads the LIVE addon folder read-only. F:\games\Ascension_wow is a NO-EDIT space.

Usage:
    py macros\tools\ingest_addon_reference.py
"""
import hashlib
import json
import re
import sys
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ADDONS = Path(r"F:\games\Ascension_wow\resources\ascension-live\Interface\AddOns")
OUT = ROOT / "macros" / "reference"

TARGETS = [
    {"name": "Asc_MacroBank",
     "standing": "SECONDARY - MAINTAINED FOR ASCENSION ('Xan(Ascension Updates)'), so its "
                 "assumptions aim at THIS client. Still an author's belief, not proof."},
    {"name": "SuperDuperMacro",
     "standing": "SECONDARY - retail-WotLK-derived (Interface 30300). Its interpreter is "
                 "'adapted from ChatFrame.lua' but covers only spell-yielding commands."},
]

# Conditional heads worth believing when they appear inside a [..] clause. A bare regex
# over `[...]` cannot tell a macro clause from LUA TABLE INDEXING - `[group]`, `[button]`
# and `[target]` all matched as "conditionals" on the first run and were every one of them
# `sdm_exclusiveGroups[group]` / `AceConsole.weakcommands[target]`. The clause must sit in
# a STRING to count, and the head must be a known conditional name.
KNOWN_HEADS = {
    "target", "help", "harm", "exists", "noexists", "dead", "nodead", "combat", "nocombat",
    "mod", "modifier", "nomod", "nomodifier", "stance", "form", "group", "nogroup", "pet",
    "button", "btn", "channeling", "equipped", "worn", "actionbar", "bar", "bonusbar",
    "known", "spec", "talent", "stealth", "nostealth", "mounted", "flying", "indoors",
    "outdoors", "swimming", "resting", "cursor", "party", "raid", "vehicleui",
}
LIMIT_PAT = re.compile(
    r"(MAX_ACCOUNT_MACROS|MAX_CHARACTER_MACROS|MAX_MACROS)\s*(?:or\s*(\d+))?|"
    r"charLimit\s*=\s*(\d+)|string\.sub\([^,]+,\s*1,\s*(\d+)\)")


def sha256_of(p):
    h = hashlib.sha256()
    h.update(p.read_bytes())
    return h.hexdigest()


def toc(folder):
    for f in folder.glob("*.toc"):
        t = f.read_text("utf-8", "replace")
        return {k.lower(): v.strip() for k, v in
                re.findall(r"^##\s*([A-Za-z-]+)\s*:\s*(.+)$", t, re.M)}
    return {}


def scan(folder, name):
    """Attested clauses must live in a STRING and lead with a known conditional head."""
    attested, limits, files = {}, [], []
    for p in sorted(folder.rglob("*")):
        if p.suffix.lower() not in (".lua", ".xml", ".txt") or not p.is_file():
            continue
        t = p.read_text("utf-8", "replace")
        rel = f"{name}/{p.relative_to(folder).as_posix()}"
        files.append({"file": rel, "sha256": sha256_of(p), "bytes": p.stat().st_size})
        for sm in re.finditer(r'"([^"\n]*)"|\[=\[(.*?)\]=\]', t, re.S):
            s = sm.group(1) or sm.group(2) or ""
            if "[" not in s:
                continue
            for m in re.finditer(r"\[([^\]\n]+)\]", s):
                body = m.group(1).strip()
                head = re.split(r"[,:=]", body)[0].strip().lstrip("@")
                if not (body.startswith("@") or head in KNOWN_HEADS):
                    continue
                ln = t[:sm.start()].count("\n") + 1
                e = attested.setdefault(body, {"clause": body, "seen_in": [],
                                               "in_string": True})
                w = f"{rel}:{ln}"
                if w not in e["seen_in"]:
                    e["seen_in"].append(w)
        for m in LIMIT_PAT.finditer(t):
            ln = t[:m.start()].count("\n") + 1
            limits.append({"expr": m.group(0).strip(), "file": f"{rel}:{ln}"})
    return attested, limits, files


def main():
    if not ADDONS.is_dir():
        print(f"STOP: no live AddOns folder at {ADDONS}")
        sys.exit(2)
    OUT.mkdir(parents=True, exist_ok=True)
    payload = {
        "what": "The installed MACRO ADDONS as a reference source - a SECOND attested-usage "
                "channel. The client's OWN code yields ZERO conditional literals; addon code "
                "yields a few.",
        "NOT_A_FACT_SOURCE": "Nothing here is a fact about the CoA client. Downloaded != "
                             "working. An addon shipping a macro string proves its AUTHOR "
                             "BELIEVED it works on their target client - one notch stronger "
                             "than a wiki (it is code aimed at a client), still not proof. "
                             "Do not cite reference/ as basis/.",
        "standing_note": "Battlewrath, 2026-07-17: 'Whilst they aren't verified as true, they "
                         "might frame the validation better.'",
        "corroborates_the_C_wall": (
            "SuperDuperMacro's entire job is interpreting macros, and its MacroInterpreter.lua "
            "- explicitly 'adapted from ChatFrame.lua' - STILL calls SecureCmdOptionParse "
            "instead of reimplementing conditionals. An author who NEEDED the vocabulary in "
            "Lua could not get it either. INDEPENDENT support for the central finding: the "
            "vocabulary is C-side and no source read reaches it."),
        "not_a_command_mirror": (
            "SuperDuperMacro's funcsToGetSpell mirrors only the 8 commands that YIELD a "
            "spell/item (it needs the icon), NOT the command surface. Diffing it against "
            "basis/commands.json produced a bogus 41-command 'delta' that was SCOPE, not a "
            "finding. Recorded so the mistake is not repeated."),
        "noise_note": (
            "A regex over `[...]` cannot tell a macro clause from LUA TABLE INDEXING. First "
            "run 'found' [group], [button] and [target] - every one was sdm_exclusiveGroups"
            "[group] / AceConsole.weakcommands[target]. A clause now counts ONLY inside a "
            "string literal AND with a known conditional head."),
        "ingested_at": datetime.now().isoformat(timespec="seconds"),
        "ingested_by": "macros/tools/ingest_addon_reference.py",
        "source_root": str(ADDONS),
        "addons": {},
    }
    for spec in TARGETS:
        folder = ADDONS / spec["name"]
        if not folder.is_dir():
            print(f"  ! {spec['name']} not installed - skipped")
            continue
        meta = toc(folder)
        attested, limits, files = scan(folder, spec["name"])
        payload["addons"][spec["name"]] = {
            "standing": spec["standing"],
            "toc": {k: meta.get(k) for k in
                    ("title", "author", "version", "interface", "notes", "x-compatibile-with")},
            "installed_path": str(folder),
            "file_count": len(files),
            "files": files,
            "attested_clauses": dict(sorted(attested.items())),
            "attested_count": len(attested),
            "limit_expressions": limits,
        }
        print(f"  {spec['name']:18} v{meta.get('version','?'):6} iface {meta.get('interface','?')}  "
              f"{len(attested)} attested clause(s), {len(limits)} limit expr(s)")

    with open(OUT / "addon-macro-tools.json", "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=1, ensure_ascii=False)
        f.write("\n")
    tot = sum(a["attested_count"] for a in payload["addons"].values())
    print(f"\n-> reference/addon-macro-tools.json  ({tot} attested clauses total; "
          f"client's own code = 0)")


if __name__ == "__main__":
    main()
